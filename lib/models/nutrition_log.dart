import 'package:isar/isar.dart';
import 'package:hercycle_bloom/models/nutrition_enums.dart';

part 'nutrition_log.g.dart';

@collection
class NutritionLog {
  Id id = Isar.autoIncrement;

  late String userId;
  late DateTime date;
  late String itemName;
  late int calories;
  late double protein;
  late double carbs;
  late double fats;
  late double fiber;
  late double glycemicIndex;
  
  double? pcosScore;
  
  @Enumerated(EnumType.name)
  late MealType type;
  
  bool isCustom = false;
  double quantity = 1.0; 
}
