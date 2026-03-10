import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class FirestoreSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> syncCycleData({
    required DateTime lastPeriodDate,
    int cycleLength = 28,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final fcmToken = await NotificationService.getFCMToken();
      
      await _firestore.collection('users').doc(user.uid).set({
        'lastPeriodDate': Timestamp.fromDate(lastPeriodDate),
        'cycleLength': cycleLength,
        'fcmToken': fcmToken,
        'updatedAt': FieldValue.serverTimestamp(),
        'email': user.email,
        'name': user.displayName,
      }, SetOptions(merge: true));

      debugPrint('Cycle data synced to Firestore successfully');
    } catch (e) {
      debugPrint('Error syncing cycle data: $e');
    }
  }

  Future<void> updateFCMToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final fcmToken = await NotificationService.getFCMToken();
      if (fcmToken != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': fcmToken,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('FCM Token updated');
      }
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }
}
