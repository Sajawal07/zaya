import 'recipe.dart';

class DailyNutritionPlan {
  final DateTime date;
  final Recipe breakfast;
  final Recipe lunch;
  final Recipe dinner;
  final Recipe snack;

  DailyNutritionPlan({
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snack,
  });

  // Calculate totals
  int get totalCalories => breakfast.calories + lunch.calories + dinner.calories + snack.calories;
  double get totalProtein => breakfast.protein + lunch.protein + dinner.protein + snack.protein;
  double get totalCarbs => breakfast.carbs + lunch.carbs + dinner.carbs + snack.carbs;
  double get totalFats => breakfast.fats + lunch.fats + dinner.fats + snack.fats;
}
