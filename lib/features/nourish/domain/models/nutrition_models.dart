
class MealScore {
  final double totalScore; // 0 - 10
  final double insulinImpact; // 0 - 10 (Lower is usually better for PCOS)
  final double inflammationScore; // 0 - 10
  final List<ScoreFactor> factors;
  final String pcosInsight;
  final ScoreBreakdown breakdown;

  MealScore({
    required this.totalScore,
    required this.insulinImpact,
    required this.inflammationScore,
    required this.factors,
    required this.pcosInsight,
    required this.breakdown,
  });
}

class ScoreBreakdown {
  final double proteinRatio;
  final double fiberDensity;
  final double glycemicLoad;
  final double fatQuality;
  final double refinedCarbPenalty;
  final double sugarDensity;

  ScoreBreakdown({
    required this.proteinRatio,
    required this.fiberDensity,
    required this.glycemicLoad,
    required this.fatQuality,
    required this.refinedCarbPenalty,
    required this.sugarDensity,
  });
}

class ScoreFactor {
  final String label;
  final bool isPositive;
  final String detail;

  ScoreFactor({
    required this.label,
    required this.isPositive,
    required this.detail,
  });
}

class NutritionSummary {
  final int totalCalories;
  final int targetCalories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  /// Rolling average of PCOS meal scores logged today (0–10).
  /// Used for the Daily Nutrition Score card on the home screen.
  final double dailyScore;

  // Percentages
  double get proteinPercentage => (protein * 4) / (totalCalories > 0 ? totalCalories : 1) * 100;
  double get carbsPercentage => (carbs * 4) / (totalCalories > 0 ? totalCalories : 1) * 100;
  double get fatsPercentage => (fats * 9) / (totalCalories > 0 ? totalCalories : 1) * 100;
  int get remainingCalories => (targetCalories - totalCalories).clamp(0, targetCalories);

  final List<NutritionAlert> alerts;
  final List<MealRecommendation> recommendations;

  /// Returns up to 2 highest-priority alerts to avoid coaching spam.
  /// Priority: insulin > fiber > inflammation > other.
  List<NutritionAlert> get topAlerts {
    const priorityOrder = ['insulin', 'fiber', 'inflammation', 'warning', 'info'];
    final sorted = [...alerts]..sort((a, b) {
      final ai = priorityOrder.indexWhere((p) => a.type.contains(p));
      final bi = priorityOrder.indexWhere((p) => b.type.contains(p));
      final ai2 = ai < 0 ? priorityOrder.length : ai;
      final bi2 = bi < 0 ? priorityOrder.length : bi;
      return ai2.compareTo(bi2);
    });
    return sorted.take(2).toList();
  }

  NutritionSummary({
    required this.totalCalories,
    required this.targetCalories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.alerts,
    this.dailyScore = 0.0,
    this.recommendations = const [],
  });
}

class MealRecommendation {
  final String title;
  final String why;
  final List<String> benefits;
  final String imageUrl;

  MealRecommendation({
    required this.title,
    required this.why,
    required this.benefits,
    this.imageUrl = '',
  });
}

class NutritionAlert {
  final String message;
  final String type; // 'warning', 'info', 'success'
  final String suggestion;

  NutritionAlert({
    required this.message,
    required this.type,
    required this.suggestion,
  });
}
