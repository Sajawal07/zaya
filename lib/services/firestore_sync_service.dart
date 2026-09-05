import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/cycle_log.dart';
import '../models/user_metrics.dart';
import 'notification_service.dart';

class FirestoreSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncCycleData({
    required DateTime lastPeriodDate,
    required String uid,
    int cycleLength = 28,
  }) async {
    try {
      final fcmToken = await NotificationService.getFCMToken();
      
      await _firestore.collection('users').doc(uid).set({
        'lastPeriodDate': Timestamp.fromDate(lastPeriodDate),
        'cycleLength': cycleLength,
        'fcmToken': fcmToken,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('Cycle data synced to Firestore successfully');
    } catch (e) {
      debugPrint('Error syncing cycle data: $e');
    }
  }

  Future<void> syncAllCycleLogs(List<CycleLog> logs, String uid) async {
    try {
      final batch = _firestore.batch();
      final logsRef = _firestore.collection('users').doc(uid).collection('cycleLogs');

      // Delete existing logs first
      final existing = await logsRef.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      // Add all current logs
      for (final log in logs) {
        final docRef = logsRef.doc();
        batch.set(docRef, {
          'date': Timestamp.fromDate(log.date),
          'flow': log.flow,
          'mood': log.mood,
          'symptoms': log.symptoms,
          'energy': log.energy,
          'isPeriodStart': log.isPeriodStart,
          'isPeriodEnd': log.isPeriodEnd,
          'notes': log.notes,
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      debugPrint('Synced ${logs.length} cycle logs to Firestore');
    } catch (e) {
      debugPrint('Error syncing cycle logs: $e');
    }
  }

  Future<List<CycleLog>> loadCycleLogsFromFirestore(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cycleLogs')
          .orderBy('date', descending: true)
          .get();

      final logs = <CycleLog>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final log = CycleLog()
          ..userId = userId
          ..date = (data['date'] as Timestamp).toDate()
          ..flow = data['flow']
          ..mood = data['mood']
          ..symptoms = (data['symptoms'] as List<dynamic>?)?.cast<String>() ?? []
          ..energy = data['energy']
          ..isPeriodStart = data['isPeriodStart'] ?? false
          ..isPeriodEnd = data['isPeriodEnd'] ?? false
          ..notes = data['notes'];
        logs.add(log);
      }

      debugPrint('Loaded ${logs.length} cycle logs from Firestore');
      return logs;
    } catch (e) {
      debugPrint('Error loading cycle logs from Firestore: $e');
      return [];
    }
  }

  Future<void> syncUserMetrics(UserMetrics metrics, String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'lastPeriodDate': metrics.lastPeriodDate != null
            ? Timestamp.fromDate(metrics.lastPeriodDate!)
            : null,
        'height': metrics.height,
        'weight': metrics.weight,
        'age': metrics.age,
        'isPregnant': metrics.isPregnant,
        'dueDate': metrics.dueDate != null
            ? Timestamp.fromDate(metrics.dueDate!)
            : null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('User metrics synced to Firestore');
    } catch (e) {
      debugPrint('Error syncing user metrics: $e');
    }
  }

  Future<UserMetrics?> loadUserMetricsFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      final metrics = UserMetrics()
        ..userId = userId
        ..lastPeriodDate = (data['lastPeriodDate'] as Timestamp?)?.toDate()
        ..height = (data['height'] as num?)?.toDouble()
        ..weight = (data['weight'] as num?)?.toDouble()
        ..age = data['age'] as int?
        ..isPregnant = data['isPregnant'] ?? false
        ..dueDate = (data['dueDate'] as Timestamp?)?.toDate();

      debugPrint('Loaded user metrics from Firestore');
      return metrics;
    } catch (e) {
      debugPrint('Error loading user metrics from Firestore: $e');
      return null;
    }
  }

  Future<void> updateFCMToken(String uid) async {
    try {
      final fcmToken = await NotificationService.getFCMToken();
      if (fcmToken != null) {
        await _firestore.collection('users').doc(uid).update({
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