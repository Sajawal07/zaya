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
      rethrow;
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

  /// Clears only cycle-tracking dates (Reset Recent when no period starts remain).
  /// Does **not** clear height/weight/age or premium fields.
  Future<void> clearCycleTrackingFields(String uid) async {
    await _firestore.collection('users').doc(uid).set({
      'lastPeriodDate': FieldValue.delete(),
      'cycleLength': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Clears cycle + body metric fields on the user doc (Start Fresh).
  /// Never touches premium entitlements.
  Future<void> clearCycleFields(String uid, {required bool preservePremium}) async {
    // Intentionally do not touch isPremium / subscriptionType / purchaseToken / verifiedAt.
    assert(preservePremium, 'clearCycleFields must preserve premium');
    await _firestore.collection('users').doc(uid).set({
      'lastPeriodDate': FieldValue.delete(),
      'cycleLength': FieldValue.delete(),
      'isPregnant': false,
      'dueDate': FieldValue.delete(),
      'height': FieldValue.delete(),
      'weight': FieldValue.delete(),
      'age': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _deleteQueryInBatches(Query query) async {
    const pageSize = 200;
    while (true) {
      final snap = await query.limit(pageSize).get();
      if (snap.docs.isEmpty) break;
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snap.docs.length < pageSize) break;
    }
  }

  Future<void> deleteSubcollection(String uid, String subcollection) async {
    final ref =
        _firestore.collection('users').doc(uid).collection(subcollection);
    await _deleteQueryInBatches(ref);
  }

  /// Start Fresh: remove user-generated cloud data, keep premium fields.
  Future<void> clearAllUserGeneratedData(
    String uid, {
    required bool preservePremium,
  }) async {
    await deleteSubcollection(uid, 'cycleLogs');
    await deleteSubcollection(uid, 'chats');
    await deleteSubcollection(uid, 'private');
    await clearCycleFields(uid, preservePremium: preservePremium);
    debugPrint(
      'Cleared user-generated Firestore data for $uid (premium preserved)',
    );
  }

  /// Delete Account: remove entire users/{uid} tree (including premium fields).
  Future<void> deleteEntireUserTree(String uid) async {
    await deleteSubcollection(uid, 'cycleLogs');
    await deleteSubcollection(uid, 'chats');
    await deleteSubcollection(uid, 'private');
    final doc = _firestore.collection('users').doc(uid);
    final snap = await doc.get();
    if (snap.exists) {
      await doc.delete();
    }
    debugPrint('Deleted entire Firestore user tree for $uid');
  }

  /// Deletes purchase_tokens owned by [uid] (Spark-compatible; no Admin SDK).
  /// Also removes the token id stored on the user doc if present.
  Future<void> deleteOwnedPurchaseTokens(String uid) async {
    try {
      final userSnap = await _firestore.collection('users').doc(uid).get();
      final tokenOnUser = userSnap.data()?['purchaseToken'] as String?;
      if (tokenOnUser != null && tokenOnUser.isNotEmpty) {
        final ref = _firestore.collection('purchase_tokens').doc(tokenOnUser);
        final snap = await ref.get();
        if (snap.exists) {
          final owner = snap.data()?['userId'];
          if (owner == uid) {
            await ref.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('deleteOwnedPurchaseTokens (user field) warning: $e');
    }

    try {
      await _deleteQueryInBatches(
        _firestore.collection('purchase_tokens').where('userId', isEqualTo: uid),
      );
      debugPrint('Deleted owned purchase_tokens for $uid');
    } catch (e) {
      debugPrint('deleteOwnedPurchaseTokens (query) warning: $e');
      rethrow;
    }
  }

  /// Deletes problem_reports filed by [uid].
  Future<void> deleteOwnedProblemReports(String uid) async {
    try {
      await _deleteQueryInBatches(
        _firestore.collection('problem_reports').where('userId', isEqualTo: uid),
      );
      debugPrint('Deleted owned problem_reports for $uid');
    } catch (e) {
      debugPrint('deleteOwnedProblemReports warning: $e');
      rethrow;
    }
  }
}