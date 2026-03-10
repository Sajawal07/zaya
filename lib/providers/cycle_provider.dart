import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

final cycleDataProvider = FutureProvider<CycleInfo>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    return CycleInfo(currentDay: 1, phase: 'Unknown', nextPeriodDays: 28, isFertile: false, history: []);
  }

  final metrics = await db.getUserMetrics(user.uid);
  final allLogs = await db.getAllLogs(user.uid);
  final periodLogs = allLogs.where((l) => l.isPeriodStart).toList();
  final latestLog = periodLogs.isNotEmpty ? periodLogs.first : null;
  
  // Priority: Latest Log > UserMetrics.lastPeriodDate
  DateTime? lastPeriodDate = latestLog?.date ?? metrics?.lastPeriodDate;
  
  if (lastPeriodDate == null) {
    return CycleInfo(currentDay: 0, phase: 'Not Set', nextPeriodDays: 0, isFertile: false, history: []);
  }

  final now = DateTime.now();
  final difference = now.difference(lastPeriodDate).inDays;
  const cycleLength = 28; // Default, could be from metrics
  
  final currentDay = difference + 1; // Real day count, not modulo 28, to handle "late" periods
  
  String phase;
  bool isFertile = false;
  
  // Calculate phase based on cycle day
  if (currentDay <= 5) {
    phase = 'Menstrual';
  } else if (currentDay <= 11) {
    phase = 'Follicular';
  } else if (currentDay <= 17) {
    phase = 'Ovulation';
    isFertile = true;
  } else if (currentDay <= 28) {
    phase = 'Luteal';
  } else {
    phase = 'Late';
  }

  final nextPeriodDays = cycleLength - (currentDay % cycleLength);

  // Map history logs
  final List<Map<String, dynamic>> history = [];
  for (int i = 0; i < periodLogs.length && i < 6; i++) {
    final log = periodLogs[i];
    final DateTime? prevLogDate = (i + 1 < periodLogs.length) ? periodLogs[i + 1].date : null;
    
    String status = "On time";
    bool isLate = false;
    
    if (prevLogDate != null) {
      final cycleDays = log.date.difference(prevLogDate).inDays;
      if (cycleDays > 32) {
        status = "${cycleDays - 28} days late";
        isLate = true;
      } else if (cycleDays < 24) {
        status = "Early cycle";
      }
    }

    history.add({
      'month': DateFormat('MMMM').format(log.date),
      'status': status,
      'isLate': isLate,
      'date': log.date,
    });
  }

  return CycleInfo(
    currentDay: currentDay,
    phase: phase,
    nextPeriodDays: nextPeriodDays,
    isFertile: isFertile,
    lastPeriodDate: lastPeriodDate,
    history: history,
  );
});

class CycleInfo {
  final int currentDay;
  final String phase;
  final int nextPeriodDays;
  final bool isFertile;
  final DateTime? lastPeriodDate;
  final List<Map<String, dynamic>> history;

  CycleInfo({
    required this.currentDay,
    required this.phase,
    required this.nextPeriodDays,
    required this.isFertile,
    required this.history,
    this.lastPeriodDate,
  });
}
