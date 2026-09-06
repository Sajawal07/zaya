import '../../../health/domain/models/pcos_guidance.dart';
import 'package:hercycle_bloom/models/nutrition_enums.dart';

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
  final double fiber;
  final double glycemicIndex;
  final double processingLevel; // 0.0 (whole) to 1.0 (ultra-processed)
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
    required this.fiber,
    required this.glycemicIndex,
    required this.processingLevel,
    required this.ingredients,
    required this.instructions,
    required this.benefitNote,
    required this.prepTimeMinutes,
  });

  List<String> get pcosTags {
    final tags = <String>[];
    if (glycemicIndex < 55) tags.add('Low GI');
    if (fiber > 5) tags.add('High Fiber');
    if (protein > 20) tags.add('High Protein');
    if (processingLevel < 0.3) tags.add('Whole Food');
    return tags;
  }

  String get macros => 'P: ${protein}g • C: ${carbs}g • F: ${fats}g';
  String get timeStr => '$prepTimeMinutes min';
}
