import 'package:isar/isar.dart';

part 'user_metrics.g.dart';

enum HealthMode {
  standard,
  pcos,
  pregnancy,
  ttc, // Trying to Conceive
}

@collection
class UserMetrics {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  double? weight;
  double? height;
  int? age;
  double? prePregnancyWeight;
  String? activityLevel; // Sedentary, Light, Moderate, Active

  @enumerated
  HealthMode healthMode = HealthMode.standard;

  double get bmi {
    if (weight != null && height != null && height! > 0) {
      double heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return 0.0;
  }

  // BMR (Mifflin-St Jeor Equation for women)
  double get bmr {
    if (weight == null || height == null || age == null) return 0.0;
    return (10 * weight!) + (6.25 * height!) - (5 * age!) - 161;
  }

  // TDEE based on activity level
  double get tdee {
    final base = bmr;
    if (base == 0) return 0.0;
    
    switch (activityLevel?.toLowerCase()) {
      case 'sedentary':
        return base * 1.2;
      case 'light':
        return base * 1.375;
      case 'moderate':
        return base * 1.55;
      case 'active':
        return base * 1.725;
      default:
        return base * 1.2;
    }
  }

  double get dailyCalorieGoal {
    final baseTdee = tdee;
    if (baseTdee == 0) return 0.0;

    // Pregnancy always gets surplus regardless of BMI
    if (healthMode == HealthMode.pregnancy) {
      return baseTdee + 300;
    }

    // TTC gets maintenance regardless of BMI
    if (healthMode == HealthMode.ttc) {
      return baseTdee;
    }

    // For standard/PCOS modes, apply BMI-based adjustment
    // Only apply deficit if PCOS is confirmed (healthMode == pcos)
    final applyDeficit = healthMode == HealthMode.pcos;
    final b = bmi;

    if (b == 0) {
      // No BMI data — fall back to maintenance
      return baseTdee;
    }

    if (b < 18.5) {
      // Underweight: mild surplus for healthy weight gain
      return baseTdee + 250;
    } else if (b < 25) {
      // Normal: maintenance — focus on hormone balance
      return baseTdee;
    } else if (b < 30) {
      // Overweight: moderate deficit only if PCOS confirmed
      if (applyDeficit) {
        return (baseTdee - 400).clamp(1200, baseTdee);
      }
      return baseTdee;
    } else {
      // Obese (30+): larger deficit only if PCOS confirmed, never below 1200
      if (applyDeficit) {
        return (baseTdee - 600).clamp(1200, baseTdee);
      }
      return baseTdee;
    }
  }

  /// Returns a contextual note about the calorie goal if it was adjusted
  /// due to BMI category. Returns null if no special note is needed.
  String? get calorieGoalNote {
    final b = bmi;
    if (b == 0) return null;

    // Only show note if PCOS is confirmed and goal was adjusted
    if (healthMode != HealthMode.pcos) return null;

    if (b >= 25 && b < 30) {
      return 'Your goal includes a gentle calorie deficit to support healthy weight loss, which can help improve PCOS symptoms.';
    } else if (b >= 30) {
      return 'Your goal includes a moderate calorie deficit to support gradual weight loss, which can help improve PCOS and insulin resistance.';
    } else if (b < 18.5) {
      return 'Your goal includes a mild calorie surplus to support healthy weight gain.';
    }
    return null;
  }

  String get healthCategory {
    final b = bmi;
    if (b == 0) return 'Incomplete';
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Healthy';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }

  DateTime? lastUpdated;
  
  // PCOS Symptoms & Analysis
  bool irregularPeriods = false;
  bool sugarCravings = false;
  bool acne = false;
  bool hairFall = false;
  bool facialHair = false;
  bool fatigue = false;
  bool brainFog = false;
  bool anxiety = false;
  bool sleepIssues = false;
  bool recentlyStoppedPill = false;
  
  // Additional Conditions
  bool hasEndometriosis = false;
  bool hasPMDD = false;
  bool hasFibroids = false;
  bool hasAmenorrhea = false;
  bool hasThyroid = false;
  
  // Pregnancy Data
  bool isPregnant = false;
  DateTime? lastPeriodDate;
  DateTime? dueDate; // Estimated Due Date (EDD)

  // Premium Access
  bool isPremium = false;
  String? subscriptionType;
  DateTime? premiumExpiresAt;

  // Encrypted settings (stored as string)
  String? encryptedSettings;

  bool get isMetricsComplete => age != null && height != null && weight != null && activityLevel != null;
}
