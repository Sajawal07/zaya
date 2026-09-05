import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import '../models/user_metrics.dart';
import '../models/pregnancy_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

class UserMetricsNotifier extends StateNotifier<AsyncValue<UserMetrics?>> {
  final Ref ref;
  final User? user;

  UserMetricsNotifier(this.ref, this.user) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }
    
    try {
      final db = ref.read(databaseServiceProvider);
      UserMetrics? metrics = await db.getUserMetrics(user!.uid);
      
      // Sync premium flag from Firestore & handle test accounts
      metrics = await _syncPremiumStatus(user!, db, metrics);

      if (metrics != null) {
        await _migrateLegacyPregnancyData(user!.uid, metrics);
      }
      state = AsyncValue.data(metrics);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<UserMetrics?> _syncPremiumStatus(User user, DatabaseService db, UserMetrics? metrics) async {
    bool hasPremiumAccess = false;
    String subType = 'none';

    // Hardcoded test emails always premium
    if (const ['sarkrar48@gmail.com', 'hercyclebloom.test@gmail.com'].contains(user.email?.toLowerCase())) {
      hasPremiumAccess = true;
      subType = 'tester_bypass';
    } else {
      // Firestore check for premium status
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['isPremium'] == true) {
            hasPremiumAccess = true;
            subType = data['subscriptionType'] ?? 'premium';
          }
        }
      } catch (e) {
        hasPremiumAccess = metrics?.isPremium ?? false;
      }
    }

    if (metrics == null) return null;

    if (metrics.isPremium != hasPremiumAccess) {
      metrics.isPremium = hasPremiumAccess;
      metrics.subscriptionType = subType;
      await db.saveUserMetrics(metrics);
    }
    return metrics;
  }

  Future<void> _migrateLegacyPregnancyData(String userId, UserMetrics metrics) async {
    final db = ref.read(databaseServiceProvider);
    
    // If user is marked as pregnant but has no journey records, create one from legacy fields
    if (metrics.isPregnant && metrics.lastPeriodDate != null) {
      final existingJourney = await db.getActivePregnancy(userId);
      if (existingJourney == null) {
        final journey = PregnancyJourney()
          ..userId = userId
          ..startDate = metrics.lastPeriodDate!.toUtc()
          ..dueDate = metrics.dueDate?.toUtc() ?? metrics.lastPeriodDate!.add(const Duration(days: 280)).toUtc()
          ..isActive = true
          ..createdAt = DateTime.now().toUtc();
        await db.savePregnancyJourney(journey);
      }
    }
  }

  Future<void> updatePregnancyMode(bool isPregnant, {DateTime? startDate}) async {
    if (user == null) return;

    // Date Validation
    if (isPregnant && startDate != null) {
      final now = DateTime.now();
      if (startDate.isAfter(now)) {
        throw Exception('Start date cannot be in the future.');
      }
      if (now.difference(startDate).inDays > 300) {
        throw Exception('Start date is too far in the past.');
      }
    }

    final db = ref.read(databaseServiceProvider);
    
    // 1. Update UserMetrics flag
    var metrics = state.value ?? (UserMetrics()..userId = user!.uid);
    metrics.isPregnant = isPregnant;
    
    if (isPregnant && startDate != null) {
      // Check if there is already an active journey
      var active = await db.getActivePregnancy(user!.uid);
      
      if (active == null) {
        // Create a new Journey record only if none exists
        active = PregnancyJourney()
          ..userId = user!.uid
          ..startDate = startDate.toUtc()
          ..dueDate = startDate.add(const Duration(days: 280)).toUtc()
          ..isActive = true
          ..createdAt = DateTime.now().toUtc();
      } else {
        // Update the existing active journey's dates
        active.startDate = startDate.toUtc();
        active.dueDate = startDate.add(const Duration(days: 280)).toUtc();
      }
        
      await db.savePregnancyJourney(active);
      
      metrics.lastPeriodDate = startDate;
      metrics.dueDate = startDate.add(const Duration(days: 280));
    } else if (!isPregnant) {
      // Mark active journey as inactive
      final active = await db.getActivePregnancy(user!.uid);
      if (active != null) {
        active.isActive = false;
        active.endDate = DateTime.now().toUtc();
        await db.savePregnancyJourney(active);
      }
      
      final latestStart = await db.getLatestStartLog(user!.uid);
      metrics.lastPeriodDate = latestStart?.date;
      metrics.dueDate = null;
    }

    await db.saveUserMetrics(metrics);
    state = AsyncValue.data(metrics);

    // Re-schedule notifications
    if (isPregnant && startDate != null) {
      await NotificationService.onModeSwitchToPregnancy(startDate);
    } else if (!isPregnant) {
      await NotificationService.onModeSwitchToCycle(metrics.lastPeriodDate);
    }
  }

  Future<void> updateMetrics({
    int? age,
    double? height,
    double? weight,
    double? prePregnancyWeight,
    String? activityLevel,
  }) async {
    if (user == null) return;
    final db = ref.read(databaseServiceProvider);
    
    var metrics = state.value ?? (UserMetrics()..userId = user!.uid);
    if (age != null) metrics.age = age;
    if (height != null) metrics.height = height;
    if (weight != null) metrics.weight = weight;
    if (prePregnancyWeight != null) metrics.prePregnancyWeight = prePregnancyWeight;
    if (activityLevel != null) metrics.activityLevel = activityLevel;
    
    metrics.lastUpdated = DateTime.now();
    await db.saveUserMetrics(metrics);
    state = AsyncValue.data(metrics);
  }

  Future<void> refresh() => _init();
}

final userMetricsProvider = StateNotifierProvider<UserMetricsNotifier, AsyncValue<UserMetrics?>>((ref) {
  final user = ref.watch(currentUserProvider);
  return UserMetricsNotifier(ref, user);
});
