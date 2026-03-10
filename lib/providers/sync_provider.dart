import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_sync_service.dart';

final firestoreSyncServiceProvider = Provider<FirestoreSyncService>((ref) {
  return FirestoreSyncService();
});
