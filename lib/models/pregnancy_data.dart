import 'package:isar/isar.dart';

part 'pregnancy_data.g.dart';

@collection
class PregnancyJourney {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  late DateTime startDate;
  late DateTime dueDate;
  late bool isActive;
  
  DateTime? endDate; // Actual birth date or end of pregnancy
  String? outcome; // Optional: "Live Birth", etc.
  
  @Index()
  late DateTime createdAt;
}

@collection
class KickLog {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  @Index()
  late DateTime date; // Store as UTC for precision

  late int count;
  late String duration; // Format "MM:SS"
}

@collection
class PregnancyAppointment {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  late String title;
  late String doctor;
  
  @Index()
  late DateTime date;
  
  String? notes;
  late String type; // scan, checkup, test
  
  bool isReminderEnabled = true;
  int? notificationId;
}
