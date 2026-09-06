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
      
      // 2. Clear SharedPreferences active_user_uid + device-global notif toggles
      // (prefs are not UID-scoped — clear so the next account does not inherit them).
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_user_uid');
      for (final key in const [
        'notif_period_reminder',
        'notif_fertile_window',
        'notif_ovulation_day',
        'notif_pregnancy_weekly',
      ]) {
        await prefs.remove(key);
      }
      
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

  /// Re-authenticate with the same Google account (for sensitive ops like delete).
  ///
  /// [forceInteractive] (default true) signs out of Google Sign-In first so the
  /// next picker yields a **fresh** idToken — silent/cached sessions often fail
  /// Firebase's `requires-recent-login` check for account deletion.
  /// Does not switch Firebase users; rejects a different Google account.
  Future<void> reauthenticateWithGoogle({bool forceInteractive = true}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user to re-authenticate.',
      );
    }

    final expectedEmail = user.email?.toLowerCase();

    // Drop stale Google session tokens without signing out of Firebase.
    if (forceInteractive) {
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint('Google signOut before reauth warning: $e');
      }
    }

    GoogleSignInAccount? googleUser;
    if (!forceInteractive) {
      googleUser = await _googleSignIn.signInSilently();
    }
    googleUser ??= await _googleSignIn.signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'reauth-cancelled',
        message: 'Google re-authentication was cancelled.',
      );
    }

    if (expectedEmail != null &&
        googleUser.email.toLowerCase() != expectedEmail) {
      // Do not leave a different Google session active for this app.
      await _googleSignIn.signOut();
      throw FirebaseAuthException(
        code: 'user-mismatch',
        message:
            'Please use the same Google account ($expectedEmail) to confirm.',
      );
    }

    final googleAuth = await googleUser.authentication;
    if (googleAuth.idToken == null && googleAuth.accessToken == null) {
      throw FirebaseAuthException(
        code: 'missing-google-token',
        message: 'Google did not return credentials. Please try again.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await user.reauthenticateWithCredential(credential);
    debugPrint('Successfully re-authenticated: ${user.email}');
  }

  /// After Auth user is already deleted (e.g. by Cloud Function), clear Google
  /// session, prefs, and close local DB without calling Firebase signOut on a
  /// missing user.
  Future<void> signOutAfterAccountDeletion() async {
    try {
      DeviceStepService.stopListening();
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('active_user_uid');
      await prefs.remove('active_user_uid');
      if (uid != null) {
        try {
          final db = DatabaseService(uid);
          await db.close();
        } catch (_) {}
      }
      await _googleSignIn.signOut();
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }
      debugPrint('Signed out after account deletion');
    } catch (e) {
      debugPrint('Error signing out after deletion: $e');
      rethrow;
    }
  }

  bool get isSignedIn => currentUser != null;
}
