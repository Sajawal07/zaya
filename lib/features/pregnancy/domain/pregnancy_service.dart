
import '../domain/models/pregnancy_week_info.dart';

class PregnancyService {
  
  // Calculate current week and day based on Due Date or LMP
  static Map<String, int> calculateProgress({DateTime? dueDate, DateTime? lastPeriodDate}) {
    if (dueDate == null && lastPeriodDate == null) {
      return {'week': 0, 'day': 0};
    }

    DateTime now = DateTime.now();
    DateTime startOfPregnancy;

    if (lastPeriodDate != null) {
      startOfPregnancy = lastPeriodDate;
    } else {
      // Due date is 40 weeks (280 days) from start
      startOfPregnancy = dueDate!.subtract(const Duration(days: 280));
    }

    final difference = now.difference(startOfPregnancy).inDays;
    
    // Ensure we don't show negative days (future dates)
    if (difference < 0) return {'week': 0, 'day': 0};
    
    final int weeks = (difference / 7).floor();
    final int days = difference % 7;

    // Cap at 42 weeks
    if (weeks > 42) return {'week': 42, 'day': 0};

    return {'week': weeks, 'day': days};
  }

  // Get info for specific week
  static PregnancyWeekInfo getWeekInfo(int week) {
    // Safety check
    if (week < 1) week = 1;
    if (week > 42) week = 42;

    // Find closest defined week <= requested week
    // Since mock data is sparse, this ensures we always return something relevant
    final sortedKeys = _weekData.keys.toList()..sort();
    int bestKey = sortedKeys.first;
    for (final k in sortedKeys) {
      if (k <= week) {
        bestKey = k;
      } else {
        break;
      }
    }
    
    return _weekData[bestKey] ?? _weekData[1]!;
  }

  // Static data source
  static final Map<int, PregnancyWeekInfo> _weekData = {
    1: const PregnancyWeekInfo(
      week: 1,
      babySizeComparison: "Poppy Seed",
      babyEmoji: "🌱",
      babyDevelopmentHighlight: "Conception and implantation occur.",
      symptomTip: "Take prenatal vitamins with folic acid.",
    ),
    2: const PregnancyWeekInfo(
      week: 2,
      babySizeComparison: "Poppy Seed",
      babyEmoji: "🌱",
      babyDevelopmentHighlight: "Cells are dividing rapidly.",
      symptomTip: "Avoid alcohol and smoking.",
    ),
    3: const PregnancyWeekInfo(
      week: 3,
      babySizeComparison: "Grain of Salt",
      babyEmoji: "✨",
      babyDevelopmentHighlight: "Neural tube begins to form.",
      symptomTip: "Mild cramping may occur.",
    ),
    4: const PregnancyWeekInfo(
      week: 4,
      babySizeComparison: "Poppy Seed",
      babyEmoji: "🌱",
      babyDevelopmentHighlight: "Embryo implants in uterine lining.",
      symptomTip: "Fatigue and breast tenderness start.",
    ),
    5: const PregnancyWeekInfo(
      week: 5,
      babySizeComparison: "Apple Seed",
      babyEmoji: "🍎",
      babyDevelopmentHighlight: "Heart begins to beat.",
      symptomTip: "Stay hydrated to combat morning sickness.",
    ),
    6: const PregnancyWeekInfo(
      week: 6,
      babySizeComparison: "Sweet Pea",
      babyEmoji: "🫛",
      babyDevelopmentHighlight: "Facial features start forming.",
      symptomTip: "Eat small, frequent meals.",
    ),
    8: const PregnancyWeekInfo(
      week: 8,
      babySizeComparison: "Raspberry",
      babyEmoji: "🍓",
      babyDevelopmentHighlight: "Baby is moving (though you can't feel it).",
      symptomTip: "Wear a supportive bra.",
    ),
    10: const PregnancyWeekInfo(
      week: 10,
      babySizeComparison: "Prune",
      babyEmoji: "🫐",
      babyDevelopmentHighlight: "Vital organs are functioning.",
      symptomTip: "Gentle exercise can boost energy.",
    ),
    12: const PregnancyWeekInfo(
      week: 12,
      babySizeComparison: "Plum",
      babyEmoji: "🟣",
      babyDevelopmentHighlight: "Reflexes are developing.",
      symptomTip: "Heartburn? Avoid spicy foods.",
    ),
    16: const PregnancyWeekInfo(
      week: 16,
      babySizeComparison: "Avocado",
      babyEmoji: "🥑",
      babyDevelopmentHighlight: "Baby can hear your voice.",
      symptomTip: "Sleeping on your side is best.",
    ),
    20: const PregnancyWeekInfo(
      week: 20,
      babySizeComparison: "Banana",
      babyEmoji: "🍌",
      babyDevelopmentHighlight: "Halfway! You might feel kicks.",
      symptomTip: "Elevate feet to reduce swelling.",
    ),
    24: const PregnancyWeekInfo(
      week: 24,
      babySizeComparison: "Corn",
      babyEmoji: "🌽",
      babyDevelopmentHighlight: "Baby practices breathing.",
      symptomTip: "Monitor blood pressure regularly.",
    ),
    28: const PregnancyWeekInfo(
      week: 28,
      babySizeComparison: "Eggplant",
      babyEmoji: "🍆",
      babyDevelopmentHighlight: "Baby opens eyes.",
      symptomTip: "Count baby kicks daily.",
    ),
    32: const PregnancyWeekInfo(
      week: 32,
      babySizeComparison: "Squash",
      babyEmoji: "🎃",
      babyDevelopmentHighlight: "Baby gains weight rapidly.",
      symptomTip: "Pack your hospital bag.",
    ),
    36: const PregnancyWeekInfo(
      week: 36,
      babySizeComparison: "Papaya",
      babyEmoji: "🥭",
      babyDevelopmentHighlight: "Lungs are mature.",
      symptomTip: "Practice breathing exercises.",
    ),
    40: const PregnancyWeekInfo(
      week: 40,
      babySizeComparison: "Pumpkin",
      babyEmoji: "🎃",
      babyDevelopmentHighlight: "Ready to meet the world!",
      symptomTip: "Rest and wait for labor signs.",
    ),
  };
}
