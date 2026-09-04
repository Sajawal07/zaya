import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'wellness_provider.dart';
import '../models/wellness.dart';

class HealthAnalytics {
  final List<double> weightTrend;
  final List<int> stressTrend;
  final List<int> moodTrend;
  final List<int> crampsTrend;
  final String topSymptom;
  final String insight;
  /// 6 keys: Cycle, Symptoms, Diet, Activity, Stress, Sleep (values 0.0 - 1.0)
  final Map<String, double> wellnessMatrix;

  HealthAnalytics({
    this.weightTrend = const [],
    this.stressTrend = const [],
    this.moodTrend = const [],
    this.crampsTrend = const [],
    this.topSymptom = 'None',
    this.insight = 'Logging daily helps decode your body\'s messages.',
    this.wellnessMatrix = const {
      'Cycle': 0.7,
      'Symptoms': 0.8,
      'Diet': 0.6,
      'Activity': 0.5,
      'Stress': 0.7,
      'Sleep': 0.8,
    },
  });
}

final healthAnalyticsProvider = Provider<HealthAnalytics>((ref) {
  final wellnessState = ref.watch(wellnessProvider);
  if (wellnessState.history.isEmpty) return HealthAnalytics();

  final history = wellnessState.history.reversed.toList(); // Oldest first
  
  final weightTrend = history.map((e) => e.weight ?? 0.0).toList();
  final stressTrend = history.map((e) => e.stressLevel).toList();
  final moodTrend = history.map((e) => e.moodSwingLevel).toList();
  final crampsTrend = history.map((e) => e.crampsLevel).toList();

  // Find top symptom
  Map<String, int> symptomCounts = {};
  for (var log in history) {
    if (log.bloating) symptomCounts['Bloating'] = (symptomCounts['Bloating'] ?? 0) + 1;
    if (log.acne) symptomCounts['Acne'] = (symptomCounts['Acne'] ?? 0) + 1;
    if (log.hairThinning) symptomCounts['Hair Thinning'] = (symptomCounts['Hair Thinning'] ?? 0) + 1;
    if (log.facialHair) symptomCounts['Facial Hair'] = (symptomCounts['Facial Hair'] ?? 0) + 1;
  }

  String topSymptom = 'Normal';
  int maxCount = 0;
  symptomCounts.forEach((key, value) {
    if (value > maxCount) {
      maxCount = value;
      topSymptom = key;
    }
  });

  // Simple dynamic insight
  String insight = 'Your metrics are looking stable.';
  if (stressTrend.length >= 3) {
    final recentStress = stressTrend.sublist(stressTrend.length - 3);
    if (recentStress.every((s) => s > 7)) {
      insight = 'You\'ve reported high stress for 3 days. Focus on sleep and anti-inflammatory foods.';
    }
  }
  if (crampsTrend.length >= 2) {
    if (crampsTrend.last > crampsTrend[crampsTrend.length - 2]) {
      insight = 'Cramps are increasing. Try magnesium-rich foods or light stretching.';
    }
  }

  // Wellness Matrix Calculations
  double avgDiet = history.map((e) => e.dietScore).fold(0, (a, b) => a + b) / history.length;
  double avgStress = history.map((e) => e.stressLevel).fold(0, (a, b) => a + b) / history.length;
  double avgSleepQ = history.map((e) => e.sleepQuality).fold(0, (a, b) => a + b) / history.length;
  double avgSteps = history.map((e) => e.steps).fold(0, (a, b) => a + b) / history.length;
  double avgWorkout = history.map((e) => e.workoutMinutes).fold(0.0, (a, b) => a + b) / history.length;
  double avgSymptomRaw = (crampsTrend.fold(0, (a, b) => a + b) / history.length) + (moodTrend.fold(0, (a, b) => a + b) / history.length);

  final wellnessMatrix = {
    'Cycle': 0.85, // Placeholder for regularity
    'Symptoms': (1.0 - (avgSymptomRaw / 20.0)).clamp(0.1, 1.0),
    'Diet': (avgDiet / 10.0).clamp(0.1, 1.0),
    'Activity': (((avgSteps / 8000) + (avgWorkout / 30)) / 2).clamp(0.1, 1.0),
    'Stress': (1.0 - (avgStress / 10.0)).clamp(0.1, 1.0),
    'Sleep': (avgSleepQ / 10.0).clamp(0.1, 1.0),
  };

  return HealthAnalytics(
    weightTrend: weightTrend,
    stressTrend: stressTrend,
    moodTrend: moodTrend,
    crampsTrend: crampsTrend,
    topSymptom: topSymptom,
    insight: insight,
    wellnessMatrix: wellnessMatrix,
  );
});
