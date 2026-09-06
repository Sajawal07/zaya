import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class SecurityService {
  static const _storage = FlutterSecureStorage();
  static const _dbKeyPath = 'isar_encryption_key';

  /// Retrieves the existing encryption key or restores/generates a new one.
  static Future<Uint8List> getOrCreateDBKey() async {
    String? base64Key = await _storage.read(key: _dbKeyPath);
    
    final user = FirebaseAuth.instance.currentUser;

    if (base64Key == null) {
      // 1. Try to recover from Cloud if user is logged in
      if (user != null) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('private')
              .doc('security')
              .get();
          
          if (doc.exists && doc.data()?.containsKey('db_key') == true) {
            base64Key = doc.data()!['db_key'];
            await _storage.write(key: _dbKeyPath, value: base64Key);
            debugPrint('Security: Key recovered from Cloud.');
            return base64.decode(base64Key!);
          }
        } catch (e) {
          debugPrint('Security: Cloud recovery failed: $e');
        }
      }

      // 2. Generate a new 32-byte (256-bit) key
      final random = Random.secure();
      final keyBytes = Uint8List.fromList(
        List<int>.generate(32, (i) => random.nextInt(256)),
      );
      
      base64Key = base64.encode(keyBytes);
      await _storage.write(key: _dbKeyPath, value: base64Key);
      
      // 3. Backup to cloud immediately if possible
      if (user != null) {
        await backupKeyToCloud(user.uid, base64Key);
      }
      
      return keyBytes;
    }
    
    // Key exists locally, ensure it is backed up if not already
    if (user != null) {
      // We do this asynchronously to not block DB opening
      _ensureCloudBackup(user.uid, base64Key);
    }

    return base64.decode(base64Key);
  }

  static Future<void> _ensureCloudBackup(String userId, String key) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('private')
          .doc('security');
      
      final doc = await docRef.get();
      if (!doc.exists || doc.data()?.containsKey('db_key') == false) {
        await backupKeyToCloud(userId, key);
      }
    } catch (e) {
      debugPrint('Security: Cloud backup check failed: $e');
    }
  }

  static Future<void> backupKeyToCloud(String userId, String base64Key) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('private')
          .doc('security')
          .set({
            'db_key': base64Key,
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      debugPrint('Security: Key backed up to Cloud.');
    } catch (e) {
      debugPrint('Security: Cloud backup failed: $e');
    }
  }

  /// Clears key - WARNING: Data will be unrecoverable
  static Future<void> purgeKey() async {
    await _storage.delete(key: _dbKeyPath);
  }
}

