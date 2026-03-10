import 'package:isar/isar.dart';

part 'cycle_log.g.dart';

@collection
class CycleLog {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  @Index()
  late DateTime date;

  String? flow; // Light, Medium, Heavy
  
  String? mood; // Happy, Anxious, Moody
  
  List<String>? symptoms; // Cramps, Headache, etc.
  
  bool isPeriodStart = false;
  bool isPeriodEnd = false;
  
  String? notes;
}
