import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/database_provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/sync_provider.dart';
import '../models/user_metrics.dart';
import 'account_lifecycle_service.dart';
import 'notification_service.dart';

/// Centralized handler for cycle data mutations across all screens.
/// Guarantees that saving, updating, or deleting cycle logs reschedules notifications,
/// syncs to Firestore, updates UserMetrics, and invalidates UI providers.
class CycleUpdateHandler {
  static Future<void> onCycleDataChanged(dynamic ref, [String? customUid]) async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = customUid ?? user?.uid;
    if (uid == null) return;

    // User is writing real data again — allow future reinstall hydrate.
    await AccountLifecycleService.setFirestoreHydrateBlocked(uid, false);

    final db = ref.read(databaseServiceProvider);
    
    // Consolidate duplicate period starts if any
    await db.consolidatePeriodStarts(uid);

    // Get latest period start log
    final latestStartLog = await db.getLatestStartLog(uid);
    final periodDate = latestStartLog?.date;

    if (periodDate != null) {
      final metrics = await db.getUserMetrics(uid) ?? (UserMetrics()..userId = uid);
      metrics.lastPeriodDate = periodDate;
      await db.saveUserMetrics(metrics);

      try {
        await ref.read(firestoreSyncServiceProvider).syncCycleData(
              lastPeriodDate: periodDate,
              uid: uid,
            );
        final allLogs = await db.getAllLogs(uid);
        await ref.read(firestoreSyncServiceProvider).syncAllCycleLogs(allLogs, uid);
        await ref.read(firestoreSyncServiceProvider).syncUserMetrics(metrics, uid);
      } catch (e) {
        debugPrint('Cycle data sync warning: $e');
      }

      try {
        await NotificationService.scheduleCycleSequence(periodDate);
      } catch (e) {
        debugPrint('Notification rescheduling warning: $e');
      }
    } else {
      // If all logs deleted, cancel notifications
      await NotificationService.cancelCycleNotifications();
    }

    ref.invalidate(cycleDataProvider);
    try {
      ref.read(calendarRefreshKeyProvider.notifier).state++;
    } catch (_) {}
  }
}
