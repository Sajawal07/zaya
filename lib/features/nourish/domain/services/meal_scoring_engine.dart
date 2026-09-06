import 'dart:math' as math;
import '../models/nutrition_models.dart';


class MealScoringEngine {
  /// Science-Informed PCOS Score Calculation
  ///
  /// Formula (before normalization):
  ///   0.28(ProteinRatio) + 0.24(FiberDensity) + 0.24(1-GL) + 0.16(FatQuality) + 0.08(RefinedCarbPenalty)
  ///
  /// Calorie Normalization (only for meals > 700 kcal):
  ///   factor = clamp(sqrt(kcal/700), 0.9, 1.3)
  ///   – Small snacks are NOT penalised; only large high-cal meals get a mild penalty.
  ///
  /// Insulin Impact: 0.6(GL) − 0.2(Fiber) − 0.2(Protein)
  ///
  /// Inflammation: proc×3 + sugar×2 + satFat×2 + omega6Penalty − omega3×2
  ///   Omega-6 penalty only fires when omega6/omega3 > 10 (i.e. truly inflammatory ratio)
  ///
  /// `context` map is reserved for future meal-timing features:
  ///   { 'phase': 'follicular' | 'ovulatory' | 'luteal' | 'menstrual',
  ///     'state': 'fasted' | 'mixed_meal' | 'post_exercise' }
  static MealScore calculateMealScore({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    required double fiber,
    required double glycemicIndex,
    double glycemicLoad = 0,
    double saturatedFat = 0,
    double addedSugar = 0,
    bool isInflammatory = false,
    double processingLevel = 0.5,
    double omega3Index = 0,
    double omega6Load = 1,
    Map<String, dynamic>? context,
  }) {
    final factors = <ScoreFactor>[];
    final kcal = calories > 0 ? calories : 1.0;

    // ── 1. Five-Pillar Scores ──────────────────────────────────────────────

    // Protein Ratio  (target ≥ 25-30% of kcal)
    final pRatio = ((protein * 4) / kcal).clamp(0.0, 1.0);
    final proteinScore = (pRatio / 0.3).clamp(0.0, 1.0) * 10;

    // Fiber Density  (target ≥ 3 g per 100 kcal)
    final fDensity = (fiber / kcal) * 100;
    final fiberScore = (fDensity / 3.0).clamp(0.0, 1.0) * 10;

    // Glycemic Load  (inverse; target < 10 = excellent)
    final glScore = (1.0 - (glycemicLoad / 20.0).clamp(0.0, 1.0)) * 10;

    // Fat Quality  (unsaturated / total)
    final unsatFat = (fats - saturatedFat).clamp(0.0, fats);
    final fatQualityRatio = (unsatFat / (fats > 0 ? fats : 1)).clamp(0.0, 1.0);
    final fatScore = fatQualityRatio * 10;

    // Refined Carb & Sugar Penalty
    final sugarRatio = (addedSugar * 4) / kcal;
    final refinedPenaltyScore =
        (1.0 - (processingLevel * 0.7 + sugarRatio * 0.3).clamp(0.0, 1.0)) * 10;

    // ── 2. Weighted Base Score ─────────────────────────────────────────────
    final baseScore = (0.28 * proteinScore) +
        (0.24 * fiberScore) +
        (0.24 * glScore) +
        (0.16 * fatScore) +
        (0.08 * refinedPenaltyScore);

    // ── 3. Calorie Normalization (only above 700 kcal) ────────────────────
    // Small snacks should NOT get an artificial score boost.
    // Large meals (>700 kcal) get a mild, clamped penalty.
    double calorieFactor = 1.0;
    if (calories > 700) {
      calorieFactor = math.sqrt(calories / 700.0).clamp(0.9, 1.3);
    }
    final totalScore = (baseScore / calorieFactor).clamp(0.0, 10.0);

    // ── 4. Insulin Impact Model ────────────────────────────────────────────
    // Protein and fiber blunt the glycaemic response.
    final insulinImpact =
        (0.6 * (glycemicLoad / 2.0) - 0.2 * fiber - 0.2 * protein)
            .clamp(0.0, 10.0);

    // ── 5. Inflammation Score ──────────────────────────────────────────────
    // Omega-6 only penalised when ratio > 10 (nuts/seeds with balanced omega-3
    // are NOT inflammatory and should not be punished)
    final omega6Ratio = omega3Index > 0 ? omega6Load / omega3Index : omega6Load;
    final omega6Penalty = omega6Ratio > 10 ? (omega6Load / 5) * 3 : 0.0;
    double inflammScore = (processingLevel * 3 +
            (addedSugar / 10) * 2 +
            (saturatedFat / 5) * 2 +
            omega6Penalty -
            (omega3Index / 5) * 2)
        .clamp(0.0, 10.0);
    if (isInflammatory) inflammScore = (inflammScore + 1.5).clamp(0.0, 10.0);

    // ── 6. Score Factors for UI ────────────────────────────────────────────
    if (pRatio >= 0.25) {
      factors.add(ScoreFactor(
          label: 'Protein Rich',
          isPositive: true,
          detail: 'Supports muscle synthesis and blunts insulin.'));
    } else {
      factors.add(ScoreFactor(
          label: 'Low Protein',
          isPositive: false,
          detail: 'Low protein may accelerate sugar absorption.'));
    }

    if (fDensity >= 2.5) {
      factors.add(ScoreFactor(
          label: 'High Fiber',
          isPositive: true,
          detail: 'Slows digestion and supports oestrogen clearance.'));
    }

    if (glycemicLoad > 15) {
      factors.add(ScoreFactor(
          label: 'High Glycemic Load',
          isPositive: false,
          detail: 'Expect a sharper insulin and glucose spike.'));
    }

    if (calorieFactor > 1.0) {
      factors.add(ScoreFactor(
          label: 'Large Meal Volume',
          isPositive: false,
          detail: 'High energy density can strain insulin metabolism.'));
    }

    if (omega3Index > 5) {
      factors.add(ScoreFactor(
          label: 'Omega-3 Rich',
          isPositive: true,
          detail: 'Anti-inflammatory fats support ovarian function.'));
    }

    if (omega6Ratio > 10) {
      factors.add(ScoreFactor(
          label: 'High Omega-6 : Omega-3',
          isPositive: false,
          detail: 'Unfavourable fat ratio linked to systemic inflammation.'));
    }

    if (processingLevel > 0.6 || addedSugar > 5) {
      factors.add(ScoreFactor(
          label: 'Refined Ingredients',
          isPositive: false,
          detail: 'Processed carbs & sugars trigger hormonal stress.'));
    }

    return MealScore(
      totalScore: totalScore,
      insulinImpact: insulinImpact,
      inflammationScore: inflammScore,
      factors: factors,
      pcosInsight: _generateHormonalInsight(
          totalScore, insulinImpact, inflammScore, processingLevel),
      breakdown: ScoreBreakdown(
        proteinRatio: pRatio,
        fiberDensity: fDensity,
        glycemicLoad: glycemicLoad,
        fatQuality: fatQualityRatio,
        refinedCarbPenalty: 10 - refinedPenaltyScore,
        sugarDensity: sugarRatio,
      ),
    );
  }

  static String _generateHormonalInsight(
      double score, double insulin, double inflammation, double proc) {
    if (score > 8.5) {
      return "Hormone Harmony. This meal actively supports your endocrine system.";
    }
    if (insulin > 7) {
      return "High Insulin Load — consider adding more protein or fiber next time.";
    }
    if (inflammation > 6) {
      return "Elevated Inflammation — swap for whole, minimally-processed ingredients.";
    }
    if (proc > 0.7) {
      return "Ultra-processed ingredients detected — these can disrupt endocrine signals.";
    }
    return "Balanced choice. Supports steady energy and hormonal homeostasis.";
  }
}
