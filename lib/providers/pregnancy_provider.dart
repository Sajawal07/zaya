import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import '../models/pregnancy_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

final activePregnancyProvider = FutureProvider<PregnancyJourney?>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  
  return await db.getActivePregnancy(user.uid);
});

final pregnancyHistoryProvider = FutureProvider<List<PregnancyJourney>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  
  return await db.getPregnancyHistory(user.uid);
});
