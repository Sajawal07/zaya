import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'database_provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../services/firestore_sync_service.dart';
import '../core/cycle_math.dart';

import 'auth_provider.dart';

/// Increment this to force Calendar screen to refresh its data.
final calendarRefreshKeyProvider = StateProvider<int>((ref) => 0);

final cycleDataProvider = FutureProvider<CycleInfo>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return CycleInfo(
      currentDay: 1,
      phase: 'Unknown',
      nextPeriodDays: CycleMath.defaultLength,
      isFertile: false,
      history: [],
      daysUntilFertile: 0,
      isLate: false,
      cycleLength: CycleMath.defaultLength,
    );
  }

  var metrics = await db.getUserMetrics(user.uid);
  var allLogs = await db.getAllLogs(user.uid);

  // If local Isar is empty, try loading from Firestore (after reinstall)
  if (allLogs.isEmpty || metrics?.lastPeriodDate == null) {
    try {
      final firestoreService = FirestoreSyncService();

      final remoteLogs = await firestoreService.loadCycleLogsFromFirestore(user.uid);
      if (remoteLogs.isNotEmpty) {
        for (final log in remoteLogs) {
          await db.saveCycleLog(log);
        }
        allLogs = await db.getAllLogs(user.uid);
        debugPrint('Restored ${remoteLogs.length} cycle logs from Firestore');
      }

      if (metrics == null || metrics.lastPeriodDate == null) {
        final remoteMetrics = await firestoreService.loadUserMetricsFromFirestore(user.uid);
        if (remoteMetrics != null) {
          await db.saveUserMetrics(remoteMetrics);
          metrics = remoteMetrics;
          debugPrint('Restored user metrics from Firestore');
        }
      }
    } catch (e) {
      debugPrint('Error loading from Firestore: $e');
    }
  }

  // Remove duplicate period-starts (<24 days apart) from older daily-log bugs.
  final cleared = await db.consolidatePeriodStarts(user.uid);
  if (cleared > 0) {
    allLogs = await db.getAllLogs(user.uid);
    debugPrint('Cleared $cleared duplicate period-start flags');
  }

  final periodLogs = allLogs.where((l) => l.isPeriodStart).toList();
  final latestLog = periodLogs.isNotEmpty ? periodLogs.first : null;

  // Priority: Latest Log > UserMetrics.lastPeriodDate
  DateTime? lastPeriodDate = latestLog?.date ?? metrics?.lastPeriodDate;

  if (lastPeriodDate == null) {
    return CycleInfo(
      currentDay: 0,
      phase: 'Not Set',
      nextPeriodDays: 0,
      isFertile: false,
      history: [],
      daysUntilFertile: 0,
      isLate: false,
      cycleLength: CycleMath.defaultLength,
    );
  }

  // Avg of past cycles; first-time users → 28.
  final cycleLength = CycleMath.averageFromLogs(periodLogs);
  final ovulation = CycleMath.ovulationDay(cycleLength);
  final fertileStart = CycleMath.fertileStartDay(cycleLength);
  final fertileEnd = CycleMath.fertileEndDay(cycleLength);

  final now = DateTime.now();
  final start = CycleMath.dayOnly(lastPeriodDate);
  final difference = CycleMath.daysBetween(start, now);
  final currentDay = max(1, difference + 1);

  String phase;
  bool isFertile = false;

  if (currentDay <= 5) {
    phase = 'Menstrual';
  } else if (currentDay < fertileStart) {
    phase = 'Follicular';
  } else if (currentDay <= fertileEnd) {
    phase = 'Ovulation';
    isFertile = true;
  } else if (currentDay <= cycleLength) {
    phase = 'Luteal';
  } else {
    phase = 'Late';
  }

  final nextPeriodDays = cycleLength - currentDay;
  final isLate = currentDay > cycleLength;

  int daysUntilFertile = 0;
  if (currentDay < fertileStart) {
    daysUntilFertile = fertileStart - currentDay;
  } else if (currentDay > fertileEnd) {
    daysUntilFertile = -1; // Passed
  }

  final List<Map<String, dynamic>> history = [];
  for (int i = 0; i < periodLogs.length && i < 6; i++) {
    final log = periodLogs[i];
    final DateTime? prevLogDate =
        (i + 1 < periodLogs.length) ? periodLogs[i + 1].date : null;

    String status = 'On time';
    bool isLateLog = false;

    if (prevLogDate != null) {
      final cycleDays = CycleMath.daysBetween(prevLogDate, log.date);
      if (cycleDays > cycleLength + 4) {
        status = '${cycleDays - cycleLength} days late';
        isLateLog = true;
      } else if (cycleDays < 24) {
        status = 'Early cycle';
      }
    }

    history.add({
      'month': DateFormat('MMMM').format(log.date),
      'status': status,
      'isLate': isLateLog,
      'date': log.date,
      'length': prevLogDate != null ? CycleMath.daysBetween(prevLogDate, log.date) : null,
    });
  }


  return CycleInfo(
    currentDay: currentDay,
    phase: phase,
    nextPeriodDays: nextPeriodDays,
    isFertile: isFertile,
    isLate: isLate,
    daysUntilFertile: daysUntilFertile,
    lastPeriodDate: lastPeriodDate,
    history: history,
    cycleLength: cycleLength,
    ovulationCycleDay: ovulation,
  );
});

class CycleInfo {
  final int currentDay;
  final String phase;
  final int nextPeriodDays; // Positive for upcoming, negative for late
  final bool isFertile;
  final bool isLate;
  final int daysUntilFertile; // 0 if in window, positive if upcoming, -1 if passed
  final DateTime? lastPeriodDate;
  final List<Map<String, dynamic>> history;
  /// Predicted cycle length: avg of past cycles, or 28 for first-time users.
  final int cycleLength;
  final int ovulationCycleDay;

  CycleInfo({
    required this.currentDay,
    required this.phase,
    required this.nextPeriodDays,
    required this.isFertile,
    required this.isLate,
    required this.daysUntilFertile,
    required this.history,
    this.lastPeriodDate,
    this.cycleLength = CycleMath.defaultLength,
    this.ovulationCycleDay = 14,
  });

  DateTime? get nextPeriodDate {
    if (lastPeriodDate == null) return null;
    return CycleMath.dayOnly(lastPeriodDate!).add(Duration(days: cycleLength));
  }
}
