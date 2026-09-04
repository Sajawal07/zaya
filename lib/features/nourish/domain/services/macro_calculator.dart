import 'package:hercycle_bloom/models/nutrition_log.dart';

class MacroCalculator {
  static Map<String, double> sumMacros(List<NutritionLog> logs) {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fats = 0;
    double fiber = 0;

    for (var log in logs) {
      calories += log.calories;
      protein += log.protein;
      carbs += log.carbs;
      fats += log.fats;
      fiber += log.fiber;
    }

    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
    };
  }

  static double calculateGlycemicLoad(double glycemicIndex, double carbs) {
    // GL = (GI * Net Carbs) / 100
    return (glycemicIndex * carbs) / 100;
  }
}
