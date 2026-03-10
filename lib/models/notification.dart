import 'package:isar/isar.dart';

part 'notification.g.dart';

@collection
class AppNotification {
  Id id = Isar.autoIncrement;
  
  late String title;
  late String body;
  late DateTime timestamp;
  bool isRead = false;
  
  // Optional: category like 'auth' or 'cycle'
  String? category;
}
