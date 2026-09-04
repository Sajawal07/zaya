import '../models/cycle_log.dart';

/// Shared cycle-length math for predictions and reminders.
class CycleMath {
  static const int defaultLength = 28;
  static const int minLength = 21;
  static const int maxLength = 45;
  /// Typical luteal phase used to estimate ovulation from cycle length.
  static const int lutealPhaseDays = 14;

  /// Safely calculates day difference between two dates without DST truncation errors.
  static int daysBetween(DateTime start, DateTime end) {
    final a = DateTime.utc(start.year, start.month, start.day);
    final b = DateTime.utc(end.year, end.month, end.day);
    return b.difference(a).inDays;
  }

  /// Average gap between consecutive period starts.
  /// Falls back to 28 when the user has fewer than 2 valid cycles.
  static int averageCycleLength(List<DateTime> periodStarts) {
    if (periodStarts.length < 2) return defaultLength;

    final sorted = List<DateTime>.from(periodStarts)
      ..sort((a, b) => a.compareTo(b));

    final lengths = <int>[];
    for (var i = 1; i < sorted.length; i++) {
      final gap = daysBetween(sorted[i - 1], sorted[i]);
      if (gap >= minLength && gap <= maxLength) {
        lengths.add(gap);
      }
    }

    if (lengths.isEmpty) return defaultLength;
    final avg = lengths.reduce((a, b) => a + b) / lengths.length;
    return avg.round().clamp(minLength, maxLength);
  }


  static int averageFromLogs(List<CycleLog> periodStartLogs) {
    return averageCycleLength(periodStartLogs.map((l) => l.date).toList());
  }

  /// Ovulation day of cycle (1-indexed): cycleLength - 14, clamped sensibly.
  static int ovulationDay(int cycleLength) {
    final day = cycleLength - lutealPhaseDays;
    return day.clamp(10, cycleLength - 3);
  }

  /// Fertile window start day (inclusive).
  static int fertileStartDay(int cycleLength) {
    return (ovulationDay(cycleLength) - 5).clamp(8, ovulationDay(cycleLength));
  }

  /// Fertile window end day (inclusive) — day after ovulation.
  static int fertileEndDay(int cycleLength) {
    return (ovulationDay(cycleLength) + 1).clamp(
      ovulationDay(cycleLength),
      cycleLength - 1,
    );
  }

  static DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime atMorning(DateTime day, {int hour = 9}) =>
      DateTime(day.year, day.month, day.day, hour);
}
