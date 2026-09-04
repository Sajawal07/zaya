import '../models/nutrition_models.dart';
import 'macro_calculator.dart';
import 'package:hercycle_bloom/models/nutrition_log.dart';

class NutritionEngine {
  static NutritionSummary calculateSummary({
    required List<NutritionLog> logs,
    int targetCalories = 2000,
  }) {
    final totals = MacroCalculator.sumMacros(logs);

    // Calculate daily score as average of individual meal PCOS scores
    double dailyScore = 0.0;
    final scoredLogs = logs.where((l) => l.pcosScore != null && l.pcosScore! > 0).toList();
    if (scoredLogs.isNotEmpty) {
      double totalScore = 0.0;
      for (final log in scoredLogs) {
        totalScore += log.pcosScore!;
      }
      dailyScore = (totalScore / scoredLogs.length).clamp(0.0, 10.0);
    }

    // Generate smart alerts and coaching insights
    final summary = NutritionSummary(
      totalCalories: totals['calories']!.toInt(),
      targetCalories: targetCalories,
      protein: totals['protein']!,
      carbs: totals['carbs']!,
      fats: totals['fats']!,
      fiber: totals['fiber']!,
      alerts: [],
      dailyScore: dailyScore,
    );

    final alerts = _generateCoachingInsights(summary, logs);
    final recommendations = _generateRecommendations(summary, logs);
    
    return NutritionSummary(
      totalCalories: summary.totalCalories,
      targetCalories: summary.targetCalories,
      protein: summary.protein,
      carbs: summary.carbs,
      fats: summary.fats,
      fiber: summary.fiber,
      alerts: alerts,
      recommendations: recommendations,
      dailyScore: dailyScore,
    );
  }

  /// Calculate the hormone-support score for a single day's logs.
  /// Returns a score from 0.0 to 10.0, or null if no logs exist.
  static double? calculateDayScore(List<NutritionLog> dayLogs) {
    if (dayLogs.isEmpty) return null;
    final scored = dayLogs.where((l) => l.pcosScore != null && l.pcosScore! > 0).toList();
    if (scored.isEmpty) return null;
    double total = 0.0;
    for (final log in scored) {
      total += log.pcosScore!;
    }
    return (total / scored.length).clamp(0.0, 10.0);
  }

  static List<MealRecommendation> _generateRecommendations(NutritionSummary summary, List<NutritionLog> logs) {
    final recommendations = <MealRecommendation>[];

    if (summary.fiber < 15 || summary.carbsPercentage > 50) {
      recommendations.add(MealRecommendation(
        title: 'Grilled Salmon with Quinoa',
        why: 'Counteracts high insulin load with Omega-3 and slow-release fiber.',
        benefits: ['Blunts insulin response', 'High hormone-clearing fiber', 'Reduces androgen levels'],
      ));
    }

    bool isInflammatory = logs.any((l) => (l.pcosScore ?? 10) < 5.0);
    if (isInflammatory) {
      recommendations.add(MealRecommendation(
        title: 'Anti-Inflammatory Lentil Soup',
        why: 'Plant-based protein and high fiber help lower CRP levels.',
        benefits: ['High fiber', 'Anti-inflammatory spices', 'Gut health support'],
      ));
    }

    if (recommendations.isEmpty) {
      recommendations.add(MealRecommendation(
        title: 'Avocado & Egg Breakfast Bowl',
        why: 'Healthy fats and lean protein for steady morning hormones.',
        benefits: ['Steady energy', 'Healthy ovulation support', 'Zero refined carbs'],
      ));
    }

    return recommendations;
  }

  static List<NutritionAlert> _generateCoachingInsights(NutritionSummary summary, List<NutritionLog> logs) {
    final alerts = <NutritionAlert>[];

    if (summary.carbsPercentage > 45) {
      alerts.add(NutritionAlert(
        message: "High Insulin Load",
        type: 'warning',
        suggestion: "Your carbs are slightly high today. Try a low GI dinner like grilled fish with leafy greens.",
      ));
    }

    if (summary.totalCalories > 1000 && summary.fiber < 20) {
      alerts.add(NutritionAlert(
        message: "Fiber Intake Low",
        type: 'info',
        suggestion: "Fiber helps clear excess estrogen. Add chia seeds, hemp hearts, or lentils to your next meal.",
      ));
    }

    bool hasInflammatoryLog = logs.any((l) => (l.pcosScore ?? 10) < 5.0);
    if (hasInflammatoryLog) {
      alerts.add(NutritionAlert(
        message: "Inflammation Detected",
        type: 'warning',
        suggestion: "Some recent meals triggered inflammation. Focus on turmeric, ginger, and Omega-3s tonight.",
      ));
    }

    if (summary.proteinPercentage >= 25 && summary.fiber >= 25) {
      alerts.add(NutritionAlert(
        message: "Hormone Harmony",
        type: 'success',
        suggestion: "Perfect protein and fiber balance! You're giving your body the best tools for hormone regulation.",
      ));
    }

    return alerts;
  }
}
