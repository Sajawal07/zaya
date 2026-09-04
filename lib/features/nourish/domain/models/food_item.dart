/// Rich metadata model for PCOS-centric food tracking.
///
/// Design notes:
/// - `glycemicLoadEstimate` is pre-computed (GL = GI × carbs / 100) to avoid
///   expensive recalculation on every score pass.
/// - `typicalOilRangeG` expresses cooking oil uncertainty as [min, max] grams.
///   This feeds the oil-chip defaults in the AI scan step, anchoring user
///   estimates rather than letting them guess from scratch.
/// - `processingLevel` follows the NOVA classification: 0.0 = minimally processed,
///   1.0 = ultra-processed (UPF).
class FoodItem {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double glycemicIndex;
  final double glycemicLoad;          // snapshot GL (avoids repeated GI×carbs/100)
  final double glycemicLoadEstimate;  // per-serving GL estimate for scoring engine
  final double saturatedFat;
  final double addedSugar;
  final bool isInflammatory;
  final String category;
  final double processingLevel;       // 0.0 (whole) → 1.0 (ultra-processed)
  final double omega3Index;           // 0-10, higher = better
  final double omega6Load;            // 0-10, lower = better
  final bool isHormoneFriendly;       // PCOS suitability flag
  final List<double> typicalOilRangeG; // [minG, maxG] fat from cooking oil

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.glycemicIndex,
    this.glycemicLoad = 0,
    this.glycemicLoadEstimate = 0,
    this.saturatedFat = 0,
    this.addedSugar = 0,
    this.isInflammatory = false,
    this.category = 'General',
    this.processingLevel = 0.2,
    this.omega3Index = 0,
    this.omega6Load = 1,
    this.isHormoneFriendly = true,
    this.typicalOilRangeG = const [0, 0],
  });

  /// Mid-point of the typical oil range in grams (used as default estimate).
  double get typicalOilMidG =>
      typicalOilRangeG.length == 2
          ? (typicalOilRangeG[0] + typicalOilRangeG[1]) / 2
          : 0;

  /// Extra calories added by typical cooking oil at midpoint (9 kcal/g).
  int get oilCaloriesEstimate => (typicalOilMidG * 9).round();

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] ?? '',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      fats: (map['fats'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
      glycemicIndex: (map['glycemicIndex'] as num?)?.toDouble() ?? 50.0,
      glycemicLoad: (map['glycemicLoad'] as num?)?.toDouble() ?? 0.0,
      glycemicLoadEstimate:
          (map['glycemicLoadEstimate'] as num?)?.toDouble() ?? 0.0,
      saturatedFat: (map['saturatedFat'] as num?)?.toDouble() ?? 0.0,
      addedSugar: (map['addedSugar'] as num?)?.toDouble() ?? 0.0,
      isInflammatory: map['isInflammatory'] ?? false,
    );
  }
}
