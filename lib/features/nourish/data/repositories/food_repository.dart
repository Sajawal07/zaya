import '../../domain/models/food_item.dart';

/// Evidence-informed food database with PCOS-relevant metadata.
///
/// Fields guide:
///   processingLevel  – 0.0 (whole food) → 1.0 (ultra-processed / UPF)
///   omega3Index      – Relative omega-3 richness  0-10  (higher = better)
///   omega6Load       – Relative omega-6 burden     0-10  (lower = better)
///   isHormoneFriendly – General PCOS suitability flag
class FoodRepository {
  static final List<FoodItem> _mainDatabase = [
    // ── Proteins ───────────────────────────────────────────────────────────
    FoodItem(
      name: 'Egg',
      calories: 155, protein: 13, carbs: 1.1, fats: 11, fiber: 0,
      glycemicIndex: 0, glycemicLoadEstimate: 0, saturatedFat: 3.1,
      processingLevel: 0.1, omega3Index: 3, omega6Load: 2,
      isHormoneFriendly: true,
      typicalOilRangeG: [0, 5], // plain boiled=0, fried up to 5g
    ),
    FoodItem(
      name: 'Chicken Breast',
      calories: 165, protein: 31, carbs: 0, fats: 3.6, fiber: 0,
      glycemicIndex: 0, glycemicLoadEstimate: 0, saturatedFat: 1.0,
      processingLevel: 0.1, omega3Index: 1, omega6Load: 2,
      isHormoneFriendly: true,
      typicalOilRangeG: [0, 8],
    ),
    FoodItem(
      name: 'Salmon',
      calories: 208, protein: 20, carbs: 0, fats: 13, fiber: 0,
      glycemicIndex: 0, glycemicLoadEstimate: 0, saturatedFat: 3.0,
      processingLevel: 0.1, omega3Index: 9, omega6Load: 1,
      isHormoneFriendly: true,
      typicalOilRangeG: [0, 5],
    ),
    FoodItem(
      name: 'Greek Yogurt',
      calories: 59, protein: 10, carbs: 3.6, fats: 0.4, fiber: 0,
      glycemicIndex: 12, glycemicLoadEstimate: 4, saturatedFat: 0.2,
      processingLevel: 0.2, omega3Index: 1, omega6Load: 1,
      isHormoneFriendly: true,
      typicalOilRangeG: [0, 0],
    ),

    // ── Vegetables & Legumes ───────────────────────────────────────────────
    FoodItem(
      name: 'Spinach',
      calories: 23, protein: 2.9, carbs: 3.6, fats: 0.4, fiber: 2.2,
      glycemicIndex: 15, saturatedFat: 0,
      processingLevel: 0.1, omega3Index: 2, omega6Load: 1,
      isHormoneFriendly: true,
    ),
    FoodItem(
      name: 'Masoor Dal',
      calories: 116, protein: 9, carbs: 20, fats: 0.4, fiber: 8,
      glycemicIndex: 25, saturatedFat: 0,
      processingLevel: 0.1, omega3Index: 1, omega6Load: 1,
      isHormoneFriendly: true,
    ),
    FoodItem(
      name: 'Avocado',
      calories: 160, protein: 2, carbs: 8.5, fats: 15, fiber: 6.7,
      glycemicIndex: 15, saturatedFat: 2.1,
      processingLevel: 0.1, omega3Index: 2, omega6Load: 2,
      isHormoneFriendly: true,
    ),

    // ── Grains & Carbs ─────────────────────────────────────────────────────
    FoodItem(
      name: 'Oats',
      calories: 389, protein: 16.9, carbs: 66, fats: 6.9, fiber: 10.6,
      glycemicIndex: 55, saturatedFat: 1.2,
      processingLevel: 0.2, omega3Index: 1, omega6Load: 2,
      isHormoneFriendly: true,
    ),
    FoodItem(
      name: 'Brown Rice',
      calories: 110, protein: 2.6, carbs: 23, fats: 0.9, fiber: 1.8,
      glycemicIndex: 50, saturatedFat: 0.2,
      processingLevel: 0.1, omega3Index: 0, omega6Load: 2,
      isHormoneFriendly: true,
    ),
    FoodItem(
      name: 'White Rice',
      calories: 130, protein: 2.7, carbs: 28, fats: 0.3, fiber: 0.4,
      glycemicIndex: 70, saturatedFat: 0.1,
      processingLevel: 0.5, omega3Index: 0, omega6Load: 1,
      isHormoneFriendly: false,
    ),
    FoodItem(
      name: 'Whole Wheat Roti',
      calories: 85, protein: 3, carbs: 18, fats: 0.5, fiber: 3,
      glycemicIndex: 55, saturatedFat: 0.1,
      processingLevel: 0.2, omega3Index: 0, omega6Load: 1,
      isHormoneFriendly: true,
    ),

    // ── South Asian dishes ─────────────────────────────────────────────────
    FoodItem(
      name: 'Chicken Biryani',
      calories: 480, protein: 22, carbs: 58, fats: 18, fiber: 3.5,
      glycemicIndex: 65, glycemicLoadEstimate: 38, saturatedFat: 6, addedSugar: 2,
      processingLevel: 0.4, omega3Index: 1, omega6Load: 5,
      isHormoneFriendly: false,
      typicalOilRangeG: [10, 28], // 1–3 tbsp typical in restaurant biryani
    ),
    FoodItem(
      name: 'Paratha',
      calories: 260, protein: 5, carbs: 35, fats: 12, fiber: 1.5,
      glycemicIndex: 75, glycemicLoadEstimate: 26, saturatedFat: 5, addedSugar: 0,
      processingLevel: 0.6, omega3Index: 0, omega6Load: 6,
      isHormoneFriendly: false,
      typicalOilRangeG: [8, 20], // ghee/oil used during cooking
    ),
    FoodItem(
      name: 'Chicken Karahi',
      calories: 350, protein: 28, carbs: 8, fats: 24, fiber: 2,
      glycemicIndex: 10, glycemicLoadEstimate: 8, saturatedFat: 8, addedSugar: 0,
      processingLevel: 0.4, omega3Index: 1, omega6Load: 6,
      isHormoneFriendly: false,
      typicalOilRangeG: [8, 30], // restaurant versions notoriously oily
    ),
    FoodItem(
      name: 'Saag',
      calories: 95, protein: 5, carbs: 10, fats: 5, fiber: 4,
      glycemicIndex: 15, glycemicLoadEstimate: 6, saturatedFat: 1, addedSugar: 0,
      processingLevel: 0.2, omega3Index: 3, omega6Load: 2,
      isHormoneFriendly: true,
      typicalOilRangeG: [4, 12],
    ),
    FoodItem(
      name: 'Chana Masala',
      calories: 180, protein: 9, carbs: 28, fats: 5, fiber: 8,
      glycemicIndex: 28, glycemicLoadEstimate: 8, saturatedFat: 0.5, addedSugar: 0,
      processingLevel: 0.2, omega3Index: 1, omega6Load: 2,
      isHormoneFriendly: true,
      typicalOilRangeG: [4, 10],
    ),
  ];

  /// Fuzzy-match a food name against the database.
  static FoodItem? findFood(String name) {
    final lowerName = name.toLowerCase();
    try {
      return _mainDatabase.firstWhere(
        (f) =>
            lowerName.contains(f.name.toLowerCase()) ||
            f.name.toLowerCase().contains(lowerName),
      );
    } catch (_) {
      // Fallback: match individual keywords
      final keywords = lowerName.split(' ');
      for (final k in keywords) {
        if (k.length < 3) continue;
        try {
          return _mainDatabase
              .firstWhere((f) => f.name.toLowerCase().contains(k));
        } catch (_) {}
      }
      return null;
    }
  }

  static List<FoodItem> getAll() => _mainDatabase;

  /// Returns only PCOS-friendly items.
  static List<FoodItem> getHormoneFriendly() =>
      _mainDatabase.where((f) => f.isHormoneFriendly).toList();
}
