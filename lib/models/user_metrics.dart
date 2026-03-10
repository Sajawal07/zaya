import 'package:isar/isar.dart';

part 'user_metrics.g.dart';

@collection
class UserMetrics {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  double? weight;
  double? height;
  
  double get bmi {
    if (weight != null && height != null && height! > 0) {
      // height in cm converted to meters
      double heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return 0.0;
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
  
  // Pregnancy Data
  bool isPregnant = false;
  DateTime? lastPeriodDate;
  DateTime? dueDate; // Estimated Due Date (EDD)

  // Encrypted settings (stored as string)
  String? encryptedSettings;
}
