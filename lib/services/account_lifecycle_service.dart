import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/ai/data/repositories/chat_repository.dart';
import '../providers/ai_provider.dart';
import '../providers/billing_provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/database_provider.dart';
import '../providers/health_analytics_provider.dart';
import '../providers/metrics_provider.dart';
import '../providers/nutrition_provider.dart';
import '../providers/pcos_provider.dart';
import '../providers/pregnancy_provider.dart';
import '../providers/premium_provider.dart';
import '../providers/user_settings_provider.dart';
import '../providers/wellness_provider.dart';
import 'auth_service.dart';
import 'database_service.dart';
import 'device_step_service.dart';
import 'firestore_sync_service.dart';
import 'notification_service.dart';
import 'security_service.dart';

/// Central account data lifecycle: Reset Recent, Start Fresh, Delete Account.
class AccountLifecycleService {
  AccountLifecycleService(this._ref);

  final Ref _ref;

  static String _hydrateBlockKey(String uid) => 'firestore_hydrate_blocked_$uid';
  static String _epochKey(String uid) => 'account_data_epoch_$uid';

  static const _notifPrefKeys = [
    'notif_period_reminder',
    'notif_fertile_window',
    'notif_ovulation_day',
    'notif_pregnancy_weekly',
  ];

  /// In-memory epoch: bumps on wipe so in-flight Firestore hydrates abort
  /// before writing stale remote data back into a cleared local DB.
  static final Map<String, int> _memoryEpoch = {};

  static int currentDataEpoch(String uid) => _memoryEpoch[uid] ?? 0;

  static Future<int> bumpDataEpoch(String uid) async {
    final next = currentDataEpoch(uid) + 1;
    _memoryEpoch[uid] = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_epochKey(uid), next);
    return next;
  }

  static Future<void> ensureEpochLoaded(String uid) async {
    if (_memoryEpoch.containsKey(uid)) return;
    final prefs = await SharedPreferences.getInstance();
    _memoryEpoch[uid] = prefs.getInt(_epochKey(uid)) ?? 0;
  }

  /// When true, empty local DB must NOT be refilled from Firestore
  /// (prevents Start Fresh / intentional clears from being undone).
  static Future<bool> isFirestoreHydrateBlocked(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hydrateBlockKey(uid)) ?? false;
  }

  static Future<void> setFirestoreHydrateBlocked(String uid, bool blocked) async {
    final prefs = await SharedPreferences.getInstance();
    if (blocked) {
      await prefs.setBool(_hydrateBlockKey(uid), true);
    } else {
      await prefs.remove(_hydrateBlockKey(uid));
    }
  }

  /// True if a wipe started after [epochAtStart] (abort stale hydrate writes).
  static bool isStaleHydrate(String uid, int epochAtStart) {
    return currentDataEpoch(uid) != epochAtStart;
  }

  FirestoreSyncService get _firestore => FirestoreSyncService();

  /// Invalidate all UID-scoped in-memory providers.
  /// [preservePremium] keeps premium providers warm (Start Fresh).
  void invalidateUserProviders({bool preservePremium = false}) {
    _ref.invalidate(userMetricsProvider);
    _ref.invalidate(cycleDataProvider);
    _ref.invalidate(wellnessProvider);
    _ref.invalidate(nutritionProvider);
    _ref.invalidate(healthAnalyticsProvider);
    _ref.invalidate(activePregnancyProvider);
    _ref.invalidate(pregnancyHistoryProvider);
    _ref.invalidate(pcosProvider);
    _ref.invalidate(chatMessagesProvider);
    _ref.invalidate(databaseServiceProvider);
    _ref.invalidate(pregnancyModeProvider);
    try {
      _ref.read(calendarRefreshKeyProvider.notifier).state++;
    } catch (_) {}

    if (!preservePremium) {
      _ref.invalidate(billingProvider);
      _ref.invalidate(isPremiumProvider);
      _ref.invalidate(remotePremiumFlagProvider);
    }
  }

  Future<void> _clearDeviceNotifPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in _notifPrefKeys) {
      await prefs.remove(key);
    }
  }

  /// Reset Recent Data — last 7 days of logs (local + Firestore sync).
  Future<void> resetRecentData(String uid) async {
    await ensureEpochLoaded(uid);
    final epoch = await bumpDataEpoch(uid);

    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final dayStart = DateTime(cutoff.year, cutoff.month, cutoff.day);
    final db = _ref.read(databaseServiceProvider);

    await db.deleteRecentUserLogs(uid, dayStart);

    // Push remaining cycle logs to Firestore (replaces remote cycleLogs).
    final remaining = await db.getAllLogs(uid);
    await _firestore.syncAllCycleLogs(remaining, uid);

    final latestStart = await db.getLatestStartLog(uid);
    final metrics = await db.getUserMetrics(uid);

    if (latestStart != null) {
      await _firestore.syncCycleData(
        lastPeriodDate: latestStart.date,
        uid: uid,
      );
      if (metrics != null) {
        metrics.lastPeriodDate = latestStart.date;
        // If active pregnancy journey was ended by recent reset, clear flag.
        final active = await db.getActivePregnancy(uid);
        if (active == null) {
          metrics.isPregnant = false;
          metrics.dueDate = null;
        }
        await db.saveUserMetrics(metrics);
        await _firestore.syncUserMetrics(metrics, uid);
      }
      try {
        await NotificationService.scheduleCycleSequence(latestStart.date);
      } catch (e) {
        debugPrint('Reset recent: notification reschedule warning: $e');
      }
    } else {
      // No period starts remain — clear cycle dates only (keep body metrics).
      await _firestore.clearCycleTrackingFields(uid);
      if (metrics != null) {
        metrics.lastPeriodDate = null;
        final active = await db.getActivePregnancy(uid);
        if (active == null) {
          metrics.isPregnant = false;
          metrics.dueDate = null;
        }
        await db.saveUserMetrics(metrics);
        await _firestore.syncUserMetrics(metrics, uid);
      }
      await NotificationService.cancelCycleNotifications();
    }

    if (isStaleHydrate(uid, epoch)) {
      debugPrint('Reset recent: epoch advanced during op (ok)');
    }

    invalidateUserProviders(preservePremium: true);
  }

  /// Start Fresh — wipe user-generated data; keep Auth + Premium.
  Future<void> startFresh(String uid) async {
    // Block hydrate + bump epoch BEFORE any async clear so in-flight
    // loaders cannot write remote data back after wipe.
    await setFirestoreHydrateBlocked(uid, true);
    final epoch = await bumpDataEpoch(uid);

    try {
      // 1. Cloud first so empty-local hydrate cannot restore old data.
      await _firestore.clearAllUserGeneratedData(uid, preservePremium: true);
      await ChatRepository().clearAllMessages(uid);

      // 2. Local Isar (all collections) + step prefs + notifications.
      // Use a UID-scoped instance (not only the provider) so dispose races
      // cannot skip the wipe.
      final providerDb = _ref.read(databaseServiceProvider);
      await providerDb.clearAllData();
      final dedicated = DatabaseService(uid);
      try {
        await dedicated.clearAllData();
      } finally {
        await dedicated.close();
      }

      await DeviceStepService.reset(uid);
      try {
        await NotificationService.cancelCycleNotifications();
        await NotificationService.cancelPregnancyNotifications();
      } catch (e) {
        debugPrint('Start fresh: notification cancel warning: $e');
      }

      // 3. Final local sweep — catches any late hydrate writes that raced the wipe.
      final sweep = DatabaseService(uid);
      try {
        await sweep.clearAllData();
      } finally {
        await sweep.close();
      }

      // 4. Refresh in-memory state only after disk is clean (keep premium).
      invalidateUserProviders(preservePremium: true);

      if (isStaleHydrate(uid, epoch)) {
        debugPrint('Start fresh: epoch changed during wipe');
      }
    } catch (e) {
      debugPrint('Start fresh failed: $e');
      rethrow;
    }
  }

  /// Full account deletion: interactive Google reauth → cloud cascade →
  /// Auth user → local wipe → sign out.
  ///
  /// Throws [AccountLifecycleException] with user-facing messages.
  Future<void> deleteAccount(AuthService authService) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw AccountLifecycleException(
        'You must be signed in to delete your account.',
      );
    }
    final uid = user.uid;
    final email = user.email;
    // Capture UID-scoped DB before Auth user disappears.
    final localDb = DatabaseService(uid);

    await setFirestoreHydrateBlocked(uid, true);
    await bumpDataEpoch(uid);

    // 1. Interactive Google re-authentication (fresh tokens).
    try {
      await authService.reauthenticateWithGoogle(forceInteractive: true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'reauth-cancelled') {
        throw AccountLifecycleException(
          'Google confirmation was cancelled. Tap Delete Account again when ready.',
          code: e.code,
        );
      }
      if (e.code == 'user-mismatch') {
        throw AccountLifecycleException(
          'Please confirm with the same Google account (${email ?? 'your account'}) and try again.',
          code: e.code,
        );
      }
      if (e.code == 'requires-recent-login' || e.code == 'missing-google-token') {
        throw AccountLifecycleException(
          'Google could not confirm your identity. Tap Delete Account again and complete the Google sign-in prompt with ${email ?? 'your account'}.',
          code: e.code,
        );
      }
      throw AccountLifecycleException(
        'Could not verify your Google account (${e.code}). Please try again.',
        code: e.code,
      );
    }

    // Re-read after reauth — must still be the same UID.
    final freshUser = FirebaseAuth.instance.currentUser;
    if (freshUser == null || freshUser.uid != uid) {
      throw AccountLifecycleException(
        'Authentication changed. Please sign in and try again.',
      );
    }

    // 2. Full client-side cascade (Spark / free plan — no Cloud Functions required).
    // Optional CF path if ever deployed on Blaze; otherwise client does everything.
    var cloudDeleted = false;
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('deleteUserAccount');
      final result = await callable
          .call(<String, dynamic>{})
          .timeout(const Duration(seconds: 8));
      final data = result.data;
      cloudDeleted = data is Map && data['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('deleteUserAccount CF unavailable (${e.code}): ${e.message}');
    } catch (e) {
      debugPrint('deleteUserAccount CF skipped: $e');
    }

    if (!cloudDeleted) {
      try {
        await _clientSideAccountPurge(freshUser, authService);
        cloudDeleted = true;
      } on FirebaseAuthException catch (e) {
        debugPrint('Client account purge auth error: ${e.code}');
        if (e.code == 'requires-recent-login') {
          throw AccountLifecycleException(
            'Google needs a fresh confirmation. Tap Delete Account again and complete the Google sign-in for ${email ?? 'your account'}.',
            code: e.code,
          );
        }
        throw AccountLifecycleException(
          'Could not delete your account (${e.code}). Please try again.',
          code: e.code,
        );
      } catch (e) {
        debugPrint('Client account purge failed: $e');
        throw AccountLifecycleException(
          'Could not fully delete your account data. Please try again.\n$e',
        );
      }
    }

    // 3. Local cleanup for this UID.
    try {
      await localDb.clearAllData();
      await localDb.purgeLocalDatabaseFiles();
    } catch (e) {
      debugPrint('Local DB purge warning: $e');
    }

    try {
      await DeviceStepService.reset(uid);
      await SecurityService.purgeKey();
      await NotificationService.cancelCycleNotifications();
      await NotificationService.cancelPregnancyNotifications();
      await _clearDeviceNotifPrefs();
      await setFirestoreHydrateBlocked(uid, false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_epochKey(uid));
      _memoryEpoch.remove(uid);
    } catch (e) {
      debugPrint('Local ancillary cleanup warning: $e');
    }

    invalidateUserProviders(preservePremium: false);

    // 4. Sign out Google / clear prefs.
    await authService.signOutAfterAccountDeletion();
  }

  /// Client-side full purge (Spark / free plan — no Admin SDK).
  /// Deletes purchase_tokens + problem_reports + users/{uid} tree + Auth user.
  Future<void> _clientSideAccountPurge(
    User user,
    AuthService authService,
  ) async {
    final uid = user.uid;

    // Order matters: tokens/reports while still authenticated, then user tree, then Auth.
    await _firestore.deleteOwnedPurchaseTokens(uid);
    await _firestore.deleteOwnedProblemReports(uid);
    await _firestore.deleteEntireUserTree(uid);
    try {
      await ChatRepository().clearAllMessages(uid);
    } catch (_) {}

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        await authService.reauthenticateWithGoogle(forceInteractive: true);
        final u = FirebaseAuth.instance.currentUser;
        if (u == null || u.uid != uid) {
          throw AccountLifecycleException(
            'Re-authentication failed. Please try Delete Account again.',
            code: 'requires-recent-login',
          );
        }
        await u.delete();
      } else {
        rethrow;
      }
    }
  }
}

class AccountLifecycleException implements Exception {
  AccountLifecycleException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}

final accountLifecycleServiceProvider = Provider<AccountLifecycleService>((ref) {
  return AccountLifecycleService(ref);
});
