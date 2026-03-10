class PregnancyWeekInfo {
  final int week;
  final String babySizeComparison; // e.g., "Seed", "Berry", "Lemon"
  final String babyEmoji; // Emoji for comparison (e.g., 🍌, 🍎)
  final String babyDevelopmentHighlight; // Short summary
  final String symptomTip;

  const PregnancyWeekInfo({
    required this.week,
    required this.babySizeComparison,
    required this.babyEmoji,
    required this.babyDevelopmentHighlight,
    required this.symptomTip,
  });
}
