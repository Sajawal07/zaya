import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'wellness_provider.dart';

class HealthAnalytics {
  final List<double> weightTrend;
  final List<int> stressTrend;
  final List<int> moodTrend;
  final List<int> crampsTrend;
  final String topSymptom;
  final String insight;
  /// 6 keys: Cycle, Symptoms, Diet, Activity, Stress, Sleep (values 0.0 - 1.0)
  final Map<String, double> wellnessMatrix;
  /// Categories that have actual logged data
  final Map<String, bool> hasData;
  /// Whether there's enough data for meaningful analysis (7+ days)
  final bool hasEnoughData;
  /// Actual number of days with logged data
  final int loggedDays;

  HealthAnalytics({
    this.weightTrend = const [],
    this.stressTrend = const [],
    this.moodTrend = const [],
    this.crampsTrend = const [],
    this.topSymptom = 'None',
    this.insight = 'Start logging daily wellness to see your personalized analysis.',
    this.wellnessMatrix = const {
      'Cycle': 0.0,
      'Symptoms': 0.0,
      'Diet': 0.0,
      'Activity': 0.0,
      'Stress': 0.0,
      'Sleep': 0.0,
    },
    this.hasData = const {
      'Cycle': false,
      'Symptoms': false,
      'Diet': false,
      'Activity': false,
      'Stress': false,
      'Sleep': false,
    },
    this.hasEnoughData = false,
    this.loggedDays = 0,
  });
}

final healthAnalyticsProvider = Provider<HealthAnalytics>((ref) {
  final wellnessState = ref.watch(wellnessProvider);
  
  // Minimum 7 days of logged data for meaningful analysis
  const int minDataDays = 7;
  final hasEnoughData = wellnessState.history.length >= minDataDays;
  
  if (!hasEnoughData) {
    return HealthAnalytics(loggedDays: wellnessState.history.length);
  }

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

  // Track which categories have actual logged data (non-default values)
  // A category has data if at least one log has a non-zero/non-default value for that field
  bool hasDietData = history.any((e) => e.dietScore > 0);
  bool hasStressData = history.any((e) => e.stressLevel > 0);
  bool hasSleepData = history.any((e) => e.sleepQuality > 0);
  bool hasActivityData = history.any((e) => e.steps > 0 || e.workoutMinutes > 0);
  bool hasSymptomData = history.any((e) => e.crampsLevel > 0 || e.moodSwingLevel > 0 || e.bloating || e.acne || e.hairThinning || e.facialHair);
  bool hasCycleData = history.any((e) => e.flowIntensity.isNotEmpty);

  // Wellness Matrix Calculations - only calculate for categories with data
  double avgDiet = hasDietData 
      ? history.where((e) => e.dietScore > 0).map((e) => e.dietScore).fold(0.0, (a, b) => a + b) / history.where((e) => e.dietScore > 0).length
      : 0;
  double avgStress = hasStressData
      ? history.where((e) => e.stressLevel > 0).map((e) => e.stressLevel.toDouble()).fold(0.0, (a, b) => a + b) / history.where((e) => e.stressLevel > 0).length
      : 0;
  double avgSleepQ = hasSleepData
      ? history.where((e) => e.sleepQuality > 0).map((e) => e.sleepQuality.toDouble()).fold(0.0, (a, b) => a + b) / history.where((e) => e.sleepQuality > 0).length
      : 0;
  double avgSteps = hasActivityData
      ? history.where((e) => e.steps > 0).map((e) => e.steps.toDouble()).fold(0.0, (a, b) => a + b) / history.where((e) => e.steps > 0).length
      : 0;
  double avgWorkout = hasActivityData
      ? history.where((e) => e.workoutMinutes > 0).map((e) => e.workoutMinutes.toDouble()).fold(0.0, (a, b) => a + b) / history.where((e) => e.workoutMinutes > 0).length
      : 0;
  double avgSymptomRaw = hasSymptomData
      ? (crampsTrend.where((e) => e > 0).fold(0.0, (a, b) => a + b) / crampsTrend.where((e) => e > 0).length) + 
        (moodTrend.where((e) => e > 0).fold(0.0, (a, b) => a + b) / moodTrend.where((e) => e > 0).length)
      : 0;

  final wellnessMatrix = {
    'Cycle': hasCycleData ? 0.85 : 0.0, // Placeholder for regularity - only show if cycle data exists
    'Symptoms': hasSymptomData ? (1.0 - (avgSymptomRaw / 20.0)).clamp(0.1, 1.0) : 0.0,
    'Diet': hasDietData ? (avgDiet / 10.0).clamp(0.1, 1.0) : 0.0,
    'Activity': hasActivityData ? (((avgSteps / 8000) + (avgWorkout / 30)) / 2).clamp(0.1, 1.0) : 0.0,
    'Stress': hasStressData ? (1.0 - (avgStress / 10.0)).clamp(0.1, 1.0) : 0.0,
    'Sleep': hasSleepData ? (avgSleepQ / 10.0).clamp(0.1, 1.0) : 0.0,
  };

  final hasData = {
    'Cycle': hasCycleData,
    'Symptoms': hasSymptomData,
    'Diet': hasDietData,
    'Activity': hasActivityData,
    'Stress': hasStressData,
    'Sleep': hasSleepData,
  };

  return HealthAnalytics(
    weightTrend: weightTrend,
    stressTrend: stressTrend,
    moodTrend: moodTrend,
    crampsTrend: crampsTrend,
    topSymptom: topSymptom,
    insight: insight,
    wellnessMatrix: wellnessMatrix,
    hasData: hasData,
    hasEnoughData: true,
    loggedDays: wellnessState.history.length,
  );
});
