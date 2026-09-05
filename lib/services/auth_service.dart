import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import 'database_service.dart';
import 'device_step_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    serverClientId:
        '847475352438-e7vab4fkh502ko7i9i1g9noct6kgp4kf.apps.googleusercontent.com',
  );

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Current user
  User? get currentUser => _auth.currentUser;

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      debugPrint('Successfully signed in: ${userCredential.user?.email}');
      
      // Save login notification
      try {
        final db = DatabaseService(userCredential.user?.uid);
        final notification = AppNotification()
          ..title = 'Welcome to HerCycle Bloom! ✨'
          ..body = 'You have successfully signed in with ${userCredential.user?.email}.'
          ..timestamp = DateTime.now()
          ..category = 'auth';
        await db.saveNotification(notification);
      } catch (e) {
        debugPrint('Error saving login notification: $e');
      }
      
      // Persist active user UID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_user_uid', userCredential.user!.uid);
      
      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign out - clears all account-specific state
  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      final uid = user?.uid;
      
      // 1. Stop step listening and reset step service state
      DeviceStepService.stopListening();
      if (uid != null) {
        await DeviceStepService.reset(uid);
      }
      
      // 2. Clear SharedPreferences active_user_uid
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_user_uid');
      
      // 3. Close the user's Isar database connection
      try {
        final db = DatabaseService(uid);
        await db.close();
      } catch (_) {}
      
      // 4. Sign out from Firebase and Google
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
      debugPrint('Successfully signed out');
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  bool get isSignedIn => currentUser != null;
}
