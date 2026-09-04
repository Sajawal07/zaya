import 'package:isar/isar.dart';

part 'wellness.g.dart';

@collection
class WellnessLog {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  @Index()
  late DateTime date; // Store as local date (midnight)

  // Symptoms (0-10 scale or boolean)
  int crampsLevel = 0;
  bool bloating = false;
  int moodSwingLevel = 0;
  
  // Diet & Nutrition
  int dietScore = 0; // 0-10 (Junk vs Protein/Fiber)
  int waterIntake = 0; // Number of glasses
  
  // Activity
  int steps = 0;
  int workoutMinutes = 0;
  
  // Stress & Sleep
  int stressLevel = 0; // 0-10
  double sleepHours = 0;
  int sleepQuality = 0; // 0-10 (Restfulness)

  // Cycle specific (entered daily)
  String flowIntensity = 'none'; // none, spotting, light, medium, heavy
  
  // Physical symptoms
  bool acne = false;
  bool hairThinning = false;
  bool facialHair = false;
  double? weight; // Optional daily/weekly update

  @Index()
  late DateTime createdAt;
}
