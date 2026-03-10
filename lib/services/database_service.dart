import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:zaya/models/user_metrics.dart';
import 'package:zaya/models/cycle_log.dart';
import 'package:zaya/models/nutrition_log.dart';
import 'package:zaya/models/meal_plan.dart';
import 'package:zaya/models/pregnancy_data.dart';
import 'package:zaya/models/notification.dart';
import 'package:zaya/services/security_service.dart';

class DatabaseService {
  late Future<Isar> db;

  DatabaseService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();

      // Retrieve or generate secure encryption key
      final encryptionKey = await SecurityService.getOrCreateDBKey();

      return await Isar.open(
        [
          UserMetricsSchema, 
          CycleLogSchema, 
          NutritionLogSchema, 
          DailyMealPlanSchema, 
          KickLogSchema, 
          PregnancyAppointmentSchema,
          PregnancyJourneySchema,
          AppNotificationSchema,
        ],
        directory: dir.path,
        // encryptionKey: encryptionKey, // Temporarily disabled due to env-specific compilation error
      );
    }
    return Isar.getInstance()!;
  }

  // Nutrition Log Methods
  Future<void> saveNutritionLog(NutritionLog log) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.nutritionLogs.put(log);
    });
  }

  Future<List<NutritionLog>> getNutritionLogsForDate(String userId, DateTime date) async {
    final isar = await db;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return await isar.nutritionLogs
        .filter()
        .userIdEqualTo(userId)
        .dateBetween(start, end)
        .findAll();
  }

  // Meal Plan Methods
  Future<void> saveMealPlan(DailyMealPlan plan) async {
    final isar = await db;
    // Check if a plan exists for this user and date to avoid unique index violation
    final existing = await isar.dailyMealPlans
        .filter()
        .userIdEqualTo(plan.userId)
        .dateEqualTo(plan.date)
        .findFirst();
    
    if (existing != null) {
      plan.id = existing.id;
    }

    await isar.writeTxn(() async {
      await isar.dailyMealPlans.put(plan);
    });
  }

  Future<DailyMealPlan?> getMealPlanForDate(String userId, DateTime date) async {
    final isar = await db;
    final dayOnly = DateTime(date.year, date.month, date.day);
    return await isar.dailyMealPlans
        .filter()
        .userIdEqualTo(userId)
        .dateEqualTo(dayOnly)
        .findFirst();
  }

  // User Metrics Methods
  Future<void> saveUserMetrics(UserMetrics metrics) async {
    final isar = await db;
    // Check if metrics exist for this user to avoid unique index violation
    final existing = await isar.userMetrics
        .filter()
        .userIdEqualTo(metrics.userId)
        .findFirst();
    
    if (existing != null) {
      metrics.id = existing.id;
    }

    await isar.writeTxn(() async {
      await isar.userMetrics.put(metrics);
    });
  }

  Future<UserMetrics?> getUserMetrics(String userId) async {
    final isar = await db;
    return await isar.userMetrics.filter().userIdEqualTo(userId).findFirst();
  }

  // Cycle Log Methods
  Future<void> saveCycleLog(CycleLog log) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.cycleLogs.put(log);
    });
  }

  Future<List<CycleLog>> getAllLogs(String userId) async {
    final isar = await db;
    return await isar.cycleLogs
        .filter()
        .userIdEqualTo(userId)
        .sortByDateDesc()
        .findAll();
  }

  Future<CycleLog?> getLatestStartLog(String userId) async {
    final isar = await db;
    return await isar.cycleLogs
        .filter()
        .userIdEqualTo(userId)
        .isPeriodStartEqualTo(true)
        .sortByDateDesc()
        .findFirst();
  }

  Future<void> deleteLogsAfter(DateTime date) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.cycleLogs.filter().dateGreaterThan(date).deleteAll();
    });
  }

  // Pregnancy Journey Methods
  Future<void> savePregnancyJourney(PregnancyJourney journey) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.pregnancyJourneys.put(journey);
    });
  }

  Future<PregnancyJourney?> getActivePregnancy(String userId) async {
    final isar = await db;
    return await isar.pregnancyJourneys
        .filter()
        .userIdEqualTo(userId)
        .isActiveEqualTo(true)
        .findFirst();
  }

  Future<List<PregnancyJourney>> getPregnancyHistory(String userId) async {
    final isar = await db;
    return await isar.pregnancyJourneys
        .filter()
        .userIdEqualTo(userId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // Kick Log Methods
  Future<void> saveKickLog(KickLog log) async {
    final isar = await db;
    await isar.writeTxn(() async {
      // Ensure date is UTC for consistent history tracking
      log.date = log.date.toUtc();
      await isar.kickLogs.put(log);
    });
  }

  Future<List<KickLog>> getKickLogs(String userId, {int limit = 50}) async {
    final isar = await db;
    final logs = await isar.kickLogs
        .filter()
        .userIdEqualTo(userId)
        .sortByDateDesc()
        .limit(limit)
        .findAll();
    // Convert back to local for UI
    return logs.map((l) => l..date = l.date.toLocal()).toList();
  }

  // Appointment Methods
  Future<void> saveAppointment(PregnancyAppointment apt) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.pregnancyAppointments.put(apt);
    });
  }

  Future<List<PregnancyAppointment>> getAppointments(String userId, {int limit = 50}) async {
    final isar = await db;
    return await isar.pregnancyAppointments
        .filter()
        .userIdEqualTo(userId)
        .sortByDate()
        .limit(limit)
        .findAll();
  }

  Future<void> deleteAppointment(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.pregnancyAppointments.delete(id);
    });
  }

  Future<void> clearAllData() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.cycleLogs.clear();
      await isar.userMetrics.clear();
      await isar.kickLogs.clear();
      await isar.pregnancyAppointments.clear();
      await isar.pregnancyJourneys.clear();
      await isar.appNotifications.clear();
    });
  }

  // Notification Methods
  Future<void> saveNotification(AppNotification notification) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.appNotifications.put(notification);
    });
  }

  Future<List<AppNotification>> getNotifications() async {
    final isar = await db;
    return await isar.appNotifications
        .where()
        .sortByTimestampDesc()
        .findAll();
  }

  Future<void> clearNotifications() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.appNotifications.clear();
    });
  }
}
