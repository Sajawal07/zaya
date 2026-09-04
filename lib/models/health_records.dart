import 'package:isar/isar.dart';

part 'health_records.g.dart';

@collection
class LabReport {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  @Index()
  late DateTime date;

  String? labName;

  // Markers
  double? lh;
  double? fsh;
  double? tsh;
  double? t3;
  double? t4;
  double? vitaminD;
  double? bloodSugar;
  double? insulin;

  String? notes;
}

@collection
class Medication {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  late String name;
  late String dosage;
  late String frequency; // daily, weekly, twice_daily
  late List<int> reminderTimes; // minutes from midnight (e.g., 540 for 9:00 AM)

  bool isActive = true;
  
  @Index()
  late DateTime createdAt;
}

@collection
class PhysicalMetric {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  @Index()
  late DateTime date;

  double? bbt; // Basal Body Temperature
  String? cervicalMucusTexture; // sticky, creamy, watery, egg_white
  String? cervicalMucusColor; // clear, white, yellow
}
