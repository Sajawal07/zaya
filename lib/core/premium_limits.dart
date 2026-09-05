/// Shared freemium constants — single source of truth for limits & messaging.
class PremiumLimits {
  static const int freeAiMessagesPerDay = 10;
  static const int premiumAiMessagesPerDay = 50;

  static int aiDailyLimit(bool isPremium) =>
      isPremium ? premiumAiMessagesPerDay : freeAiMessagesPerDay;
}

/// What each tier actually unlocks (keep paywall / teaser copy in sync).
class FreemiumCatalog {
  /// Free — enough value to use the app daily
  static const freeFeatures = [
    'Cycle tracking & calendar',
    'Period & symptom logging',
    'Food logging with daily macros',
    'Basic health hub (daily log, meds, metrics)',
    'Basic insights (BMI, avg cycle, weight trend)',
    'AI coach — 10 questions / day',
  ];

  /// Premium — advanced analytics worth paying for
  static const premiumFeatures = [
    'AI coach — 50 questions / day',
    'Cycle regularity score & length history',
    'Hormone nutrition score trends',
    'Coach meal recommendations',
    'Hormone impact meal matrix',
    'Hormonal / PCOS deep analysis',
    'Lab & medical reports vault',
  ];
}
