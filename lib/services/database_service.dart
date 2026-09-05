
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hercycle_bloom/models/user_metrics.dart';
import 'package:hercycle_bloom/models/cycle_log.dart';
import 'package:hercycle_bloom/models/nutrition_log.dart';
import 'package:hercycle_bloom/models/meal_plan.dart';
import 'package:hercycle_bloom/models/pregnancy_data.dart';
import 'package:hercycle_bloom/models/notification.dart';
import 'package:hercycle_bloom/models/wellness.dart';
import 'package:hercycle_bloom/models/health_records.dart';
import 'dart:io';

class DatabaseService {
  Isar? _isar;
  final String? uid;

  DatabaseService(this.uid);

  Future<Isar> get db async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    _isar = await openDB();
    return _isar!;
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbName = uid ?? 'default';
    final path = uid != null ? "${dir.path}/isar_$uid" : dir.path;

    // Create directory if it doesn't exist
    final dbDir = Directory(path);
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    if (Isar.instanceNames.contains(dbName)) {
      return Isar.getInstance(dbName)!;
    }

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
        WellnessLogSchema,
        LabReportSchema,
        MedicationSchema,
        PhysicalMetricSchema,
      ],
      name: dbName,
      directory: path,
    );
  }

  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
    }
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
    // Check for existing log with same userId and date to avoid unique index violation
    final startOfDay = DateTime(log.date.year, log.date.month, log.date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final existing = await isar.cycleLogs
        .filter()
        .userIdEqualTo(log.userId)
        .dateBetween(startOfDay, endOfDay, includeUpper: false)
        .findFirst();
    
    if (existing != null) {
      log.id = existing.id;
    }

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

  Future<CycleLog?> getLogForDate(String userId, DateTime date) async {
    final isar = await db;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return await isar.cycleLogs
        .filter()
        .userIdEqualTo(userId)
        .dateBetween(startOfDay, endOfDay, includeUpper: false)
        .findFirst();
  }

  Future<CycleLog?> getPeriodStartForDate(String userId, DateTime date) async {

    final isar = await db;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return await isar.cycleLogs
        .filter()
        .userIdEqualTo(userId)
        .isPeriodStartEqualTo(true)
        .dateBetween(startOfDay, endOfDay, includeUpper: false)
        .findFirst();
  }

  /// Finds a period-start within [windowDays] of [date].
  /// Default 23 → new periods require a ≥24 day gap.
  Future<CycleLog?> getPeriodStartNearDate(String userId, DateTime date, {int windowDays = 23}) async {
    final isar = await db;
    final day = DateTime(date.year, date.month, date.day);
    final start = day.subtract(Duration(days: windowDays));
    final end = day.add(Duration(days: windowDays + 1));
    return await isar.cycleLogs
        .filter()
        .userIdEqualTo(userId)
        .isPeriodStartEqualTo(true)
        .dateBetween(start, end, includeUpper: false)
        .sortByDateDesc()
        .findFirst();
  }

  Future<List<CycleLog>> getAllPeriodStarts(String userId) async {
    final isar = await db;
    return await isar.cycleLogs
        .filter()
        .userIdEqualTo(userId)
        .isPeriodStartEqualTo(true)
        .sortByDate()
        .findAll();
  }

  /// Clears duplicate period-start flags that are &lt;24 days apart (e.g. old daily-log bugs).
  /// Keeps the earliest start in each cluster so the ring/calendar stay correct.
  Future<int> consolidatePeriodStarts(String userId) async {
    final starts = await getAllPeriodStarts(userId);
    if (starts.length <= 1) return 0;

    DateTime? lastKeptDay;
    final toClear = <CycleLog>[];

    for (final log in starts) {
      final day = DateTime(log.date.year, log.date.month, log.date.day);
      if (lastKeptDay == null || day.difference(lastKeptDay).inDays >= 24) {
        lastKeptDay = day;
      } else {
        toClear.add(log);
      }
    }

    if (toClear.isEmpty) return 0;

    final isar = await db;
    await isar.writeTxn(() async {
      for (final log in toClear) {
        log.isPeriodStart = false;
        await isar.cycleLogs.put(log);
      }
    });
    return toClear.length;
  }

  Future<void> updateCycleLogDate(int logId, DateTime newDate) async {
    final isar = await db;
    final normalized = DateTime(newDate.year, newDate.month, newDate.day);
    await isar.writeTxn(() async {
      final log = await isar.cycleLogs.get(logId);
      if (log != null) {
        log.date = normalized;
        await isar.cycleLogs.put(log);
      }
    });
  }

  Future<void> deleteCycleLogById(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.cycleLogs.delete(id);
    });
  }

  Future<void> deleteCycleLogForDate(String userId, DateTime date) async {
    final isar = await db;
    final normalized = DateTime(date.year, date.month, date.day);
    final log = await getLogForDate(userId, normalized);
    if (log != null) {
      await isar.writeTxn(() async {
        await isar.cycleLogs.delete(log.id);
      });
    }
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
    // Inbox shows only delivered / past items — never future scheduled placeholders.
    final now = DateTime.now();
    final all = await isar.appNotifications.where().sortByTimestampDesc().findAll();
    return all.where((n) => !n.timestamp.isAfter(now)).toList();
  }

  /// Removes future-dated inbox rows (leftover from old schedule-to-Isar bug).
  Future<int> deleteFutureNotifications() async {
    final isar = await db;
    final now = DateTime.now();
    final future = await isar.appNotifications.filter().timestampGreaterThan(now).findAll();
    if (future.isEmpty) return 0;
    await isar.writeTxn(() async {
      await isar.appNotifications.deleteAll(future.map((n) => n.id).toList());
    });
    return future.length;
  }

  Future<void> clearNotifications() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.appNotifications.clear();
    });
  }

  // Wellness & Health Records
  Future<void> saveWellnessLog(WellnessLog log) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.wellnessLogs.put(log);
    });
  }

  Future<WellnessLog?> getWellnessLogForDate(String userId, DateTime date) async {
    final isar = await db;
    final dayOnly = DateTime(date.year, date.month, date.day);
    return await isar.wellnessLogs
        .filter()
        .userIdEqualTo(userId)
        .dateEqualTo(dayOnly)
        .findFirst();
  }

  Future<List<WellnessLog>> getWellnessLogs(String userId, {int limit = 30}) async {
    final isar = await db;
    return await isar.wellnessLogs
        .filter()
        .userIdEqualTo(userId)
        .sortByDateDesc()
        .limit(limit)
        .findAll();
  }

  Future<void> saveLabReport(LabReport report) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.labReports.put(report);
    });
  }

  Future<List<LabReport>> getLabReports(String userId) async {
    final isar = await db;
    return await isar.labReports
        .filter()
        .userIdEqualTo(userId)
        .sortByDateDesc()
        .findAll();
  }

  Future<void> saveMedication(Medication med) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.medications.put(med);
    });
  }

  Future<List<Medication>> getMedications(String userId) async {
    final isar = await db;
    return await isar.medications
        .filter()
        .userIdEqualTo(userId)
        .isActiveEqualTo(true)
        .findAll();
  }

  Future<void> savePhysicalMetric(PhysicalMetric metric) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.physicalMetrics.put(metric);
    });
  }

  Future<List<PhysicalMetric>> getPhysicalMetrics(String userId, {int limit = 30}) async {
    final isar = await db;
    return await isar.physicalMetrics
        .filter()
        .userIdEqualTo(userId)
        .sortByDateDesc()
        .limit(limit)
        .findAll();
  }
}
