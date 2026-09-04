import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

import 'auth_provider.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final user = ref.watch(currentUserProvider);
  final service = DatabaseService(user?.uid);
  
  ref.onDispose(() {
    service.close();
  });
  
  return service;
});
