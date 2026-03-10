import '../../../health/domain/models/pcos_guidance.dart';
import 'package:zaya/models/nutrition_enums.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String assetImagePath;
  final List<PcosPattern> categories;
  final MealType mealType;
  final int calories;
  final double protein; 
  final double carbs; 
  final double fats;
  final List<String> ingredients;
  final List<String> instructions;
  final String benefitNote;
  final int prepTimeMinutes;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.assetImagePath,
    required this.categories,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.ingredients,
    required this.instructions,
    required this.benefitNote,
    required this.prepTimeMinutes,
  });

  String get macros => 'P: ${protein}g • C: ${carbs}g • F: ${fats}g';
  String get timeStr => '${prepTimeMinutes} min';
}
