import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import '../models/user_metrics.dart';
import '../models/pregnancy_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserMetricsNotifier extends StateNotifier<AsyncValue<UserMetrics?>> {
  final Ref ref;

  UserMetricsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final db = ref.read(databaseServiceProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }
    
    try {
      final metrics = await db.getUserMetrics(user.uid);
      if (metrics != null) {
        await _migrateLegacyPregnancyData(user.uid, metrics);
      }
      state = AsyncValue.data(metrics);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
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
    final user = FirebaseAuth.instance.currentUser;
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
    var metrics = state.value ?? (UserMetrics()..userId = user.uid);
    metrics.isPregnant = isPregnant;
    
    if (isPregnant && startDate != null) {
      // Check if there is already an active journey
      var active = await db.getActivePregnancy(user.uid);
      
      if (active == null) {
        // Create a new Journey record only if none exists
        active = PregnancyJourney()
          ..userId = user.uid
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
      final active = await db.getActivePregnancy(user.uid);
      if (active != null) {
        active.isActive = false;
        active.endDate = DateTime.now().toUtc();
        await db.savePregnancyJourney(active);
      }
      
      metrics.lastPeriodDate = null;
      metrics.dueDate = null;
    }

    await db.saveUserMetrics(metrics);
    state = AsyncValue.data(metrics);
  }

  Future<void> refresh() => _init();
}

final userMetricsProvider = StateNotifierProvider<UserMetricsNotifier, AsyncValue<UserMetrics?>>((ref) {
  return UserMetricsNotifier(ref);
});
