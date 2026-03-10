
import '../models/pcos_guidance.dart';

class PcosAnalysis {
  final PcosPattern pattern;
  final String suggestion;
  final List<String> primarySymptoms;
  final double confidenceScore;
  final Map<PcosPattern, double> patternScores;

  PcosAnalysis({
    required this.pattern,
    required this.suggestion,
    required this.primarySymptoms,
    required this.confidenceScore,
    required this.patternScores,
  });
}

class PcosAnalyzer {
  static PcosAnalysis analyze({
    required double bmi,
    required bool irregularPeriods,
    required bool sugarCravings,
    required bool acne,
    required bool hairFall,
    required bool facialHair,
    required bool fatigue,
    required bool brainFog,
    required bool anxiety,
    required bool sleepIssues,
    required bool recentlyStoppedPill,
    required double dheaLevel, // 0 if unknown
  }) {
    // Scores for each category
    double insulinScore = 0;
    double leanScore = 0;
    double inflammatoryScore = 0;
    double adrenalScore = 0;
    double postPillScore = 0;

    // 1. Insulin-Resistant PCOS
    if (bmi > 25) insulinScore += 2;
    if (sugarCravings) insulinScore += 3;
    if (acne) insulinScore += 1;
    if (irregularPeriods) insulinScore += 1;

    // 2. Lean PCOS
    if (bmi <= 23 && bmi >= 17) {
      leanScore += 2;
      if (irregularPeriods) leanScore += 2;
      if (acne || facialHair || hairFall) leanScore += 2;
    }

    // 3. Inflammatory PCOS
    if (fatigue) inflammatoryScore += 2;
    if (brainFog) inflammatoryScore += 3;
    if (acne) inflammatoryScore += 2;
    if (irregularPeriods) inflammatoryScore += 1;

    // 4. Adrenal PCOS
    if (anxiety) adrenalScore += 3;
    if (sleepIssues) adrenalScore += 2;
    if (dheaLevel > 0) adrenalScore += 5; // Strong indicator
    if (irregularPeriods) adrenalScore += 1;

    // 5. Post-Pill PCOS
    if (recentlyStoppedPill) {
      postPillScore += 5;
      if (acne) postPillScore += 2;
      if (irregularPeriods) postPillScore += 2;
    }

    // Determine the result
    Map<PcosPattern, double> scores = {
      PcosPattern.insulinResistant: insulinScore,
      PcosPattern.lean: leanScore,
      PcosPattern.inflammatory: inflammatoryScore,
      PcosPattern.adrenal: adrenalScore,
      PcosPattern.postPill: postPillScore,
    };

    var bestMatch = scores.entries.reduce((a, b) => a.value > b.value ? a : b);

    if (bestMatch.value < 2) {
      return PcosAnalysis(
        pattern: PcosPattern.none,
        suggestion: "Your symptoms don't clearly match a specific PCOS pattern currently.",
        primarySymptoms: [],
        confidenceScore: 0,
        patternScores: scores,
      );
    }

    String suggestion = "";
    switch (bestMatch.key) {
      case PcosPattern.insulinResistant:
        suggestion = "Your symptoms may be showing signs of insulin-resistant PCOS.";
        break;
      case PcosPattern.lean:
        suggestion = "Your symptoms may align with lean PCOS.";
        break;
      case PcosPattern.inflammatory:
        suggestion = "Your symptoms suggest an inflammatory PCOS pattern.";
        break;
      case PcosPattern.adrenal:
        suggestion = "Your profile aligns with adrenal or stress-related PCOS.";
        break;
      case PcosPattern.postPill:
        suggestion = "You may be experiencing post-pill PCOS symptoms.";
        break;
      default:
        suggestion = "Maintenance guidance.";
    }

    return PcosAnalysis(
      pattern: bestMatch.key,
      suggestion: suggestion,
      primarySymptoms: _getPrimarySymptoms(bestMatch.key, acne, facialHair, hairFall, sugarCravings, anxiety, fatigue),
      confidenceScore: bestMatch.value,
      patternScores: scores,
    );
  }

  static List<String> _getPrimarySymptoms(PcosPattern pattern, bool acne, bool facialHair, bool hairFall, bool sugarCravings, bool anxiety, bool fatigue) {
    List<String> list = [];
    if (acne) list.add("Acne");
    if (facialHair) list.add("Facial Hair");
    if (hairFall) list.add("Hair Fall");
    if (sugarCravings) list.add("Sugar Cravings");
    if (anxiety) list.add("Anxiety");
    if (fatigue) list.add("Fatigue");
    return list;
  }
}
