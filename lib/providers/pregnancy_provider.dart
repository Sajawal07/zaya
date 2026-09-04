import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import '../models/pregnancy_data.dart';

import 'auth_provider.dart';

final activePregnancyProvider = FutureProvider<PregnancyJourney?>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  return await db.getActivePregnancy(user.uid);
});

final pregnancyHistoryProvider = FutureProvider<List<PregnancyJourney>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  return await db.getPregnancyHistory(user.uid);
});
