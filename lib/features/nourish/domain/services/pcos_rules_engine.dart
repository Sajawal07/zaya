import '../models/nutrition_models.dart';

class PcosRulesEngine {
  static MealScore calculateMealScore({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    required double fiber,
    required double glycemicIndex,
    double processingLevel = 0.3,
  }) {
    double score = 10.0;
    final factors = <ScoreFactor>[];

    // 1. Glycemic Index (Critical for Insulin Resistance)
    if (glycemicIndex < 55) {
      factors.add(ScoreFactor(label: 'Low GI', isPositive: true, detail: 'Helps maintain stable insulin levels.'));
    } else {
      score -= 2.5;
      factors.add(ScoreFactor(label: 'High GI', isPositive: false, detail: 'May cause insulin spikes.'));
    }

    // 2. Fiber (Critical for hormone regulation)
    double fiberDensity = (fiber / (calories > 0 ? calories : 1)) * 100;
    if (fiberDensity > 2.0 || fiber > 6.0) {
      factors.add(ScoreFactor(label: 'High Fiber', isPositive: true, detail: 'Great for estrogen metabolism.'));
    } else {
      score -= 1.0;
      factors.add(ScoreFactor(label: 'Low Fiber', isPositive: false, detail: 'Try adding leafy greens or seeds.'));
    }

    // 3. Protein Ratio
    double proteinPercentage = (protein * 4) / (calories > 0 ? calories : 1);
    if (proteinPercentage > 0.25) {
      factors.add(ScoreFactor(label: 'High Protein', isPositive: true, detail: 'Excellent for satiety and muscle retention.'));
    } else if (proteinPercentage < 0.15) {
      score -= 1.5;
      factors.add(ScoreFactor(label: 'Low Protein', isPositive: false, detail: 'Consider adding a lean protein source.'));
    }

    // 4. Processing Level
    if (processingLevel > 0.6) {
      score -= 2.0;
      factors.add(ScoreFactor(label: 'Processed', isPositive: false, detail: 'Limit ultra-processed ingredients.'));
    }

    // Final Insight
    String insight = "This meal is generally good for PCOS.";
    if (score < 6.0) {
      insight = "This meal might trigger insulin spikes. Try balancing with fiber.";
    } else if (score > 8.5) {
      insight = "Excellent PCOS-friendly choice!";
    }

    return MealScore(
      totalScore: score.clamp(0.0, 10.0),
      insulinImpact: (glycemicIndex / 10).clamp(0.0, 10.0),
      inflammationScore: (processingLevel * 10).clamp(0.0, 10.0),
      factors: factors,
      pcosInsight: insight,
      breakdown: ScoreBreakdown(
        proteinRatio: proteinPercentage,
        fiberDensity: fiberDensity,
        glycemicLoad: (glycemicIndex * carbs) / 100,
        fatQuality: 0.8,
        refinedCarbPenalty: (processingLevel * 10).clamp(0.0, 10.0),
        sugarDensity: 0.0,
      ),
    );
  }

  static List<NutritionAlert> generateDailyAlerts(NutritionSummary summary) {
    final alerts = <NutritionAlert>[];

    // Carb Check
    if (summary.carbsPercentage > 50) {
      alerts.add(NutritionAlert(
        message: 'High Carb Intake',
        type: 'warning',
        suggestion: 'Reduce high GI carbs tonight. Try grilled chicken with vegetables.',
      ));
    }

    // Fiber Check
    if (summary.fiber < 15) {
      alerts.add(NutritionAlert(
        message: 'Low Fiber Alert',
        type: 'info',
        suggestion: 'Add chia seeds, hemp hearts, or lentils to your next meal.',
      ));
    }

    // Protein Check
    if (summary.totalCalories > 1000 && summary.proteinPercentage < 20) {
      alerts.add(NutritionAlert(
        message: 'Low Protein detected',
        type: 'warning',
        suggestion: 'Increase protein to help balance hormones and improve satiety.',
      ));
    }

    return alerts;
  }
}
