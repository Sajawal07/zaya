import 'package:isar/isar.dart';

part 'meal_plan.g.dart';

@collection
class DailyMealPlan {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;
  
  @Index()
  late DateTime date; // Store only the date part
  
  late String pcosPattern;
  
  late String breakfastRecipeId;
  late String lunchRecipeId;
  late String dinnerRecipeId;
  late List<String> snackRecipeIds;
  
  late List<String> loggedMealTypes; // List of MealType names that are "consumed"
  
  // Storing adjustments
  late double breakfastPortion;
  late double lunchPortion;
  late double dinnerPortion;

  DailyMealPlan() {
    breakfastPortion = 1.0;
    lunchPortion = 1.0;
    dinnerPortion = 1.0;
    snackRecipeIds = [];
    loggedMealTypes = [];
  }
}
