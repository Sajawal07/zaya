# Firebase Backend Setup - Zaya Wellness App

## ✅ What's Been Configured

### Firebase Project Created
- **Project ID**: `zaya-wellness-2026`
- **Project Number**: `65602568709`
- **Display Name**: Zaya Wellness App
- **Region**: Asia South (asia-south1)

### Services Initialized

#### 1. **Firebase Authentication**
- ✅ Google Sign-In enabled
- ✅ Email/Password authentication enabled
- OAuth Brand: "Zaya"
- Support Email: sajawal0005@gmail.com

#### 2. **Cloud Firestore Database**
- ✅ Database created: `(default)`
- ✅ Location: `asia-south1`
- ✅ Security rules configured for user data isolation

#### 3. **Firebase Storage**
- ✅ Storage bucket: `zaya-wellness-2026.firebasestorage.app`
- ✅ Security rules configured for user profile images

### Android App Registered
- **App ID**: `1:65602568709:android:f13235c0037b6d9ae2126c`
- **Package Name**: `com.zaya.zaya`
- **Display Name**: Zaya Android
- ✅ `google-services.json` generated and saved

## 📁 Files Created

1. **`.firebaserc`** - Firebase project configuration
2. **`firebase.json`** - Firebase features configuration
3. **`firestore.rules`** - Firestore security rules
4. **`storage.rules`** - Storage security rules
5. **`android/app/google-services.json`** - Android app configuration
6. **`lib/firebase_options.dart`** - Flutter Firebase options

## 🔒 Security Rules

### Firestore Rules
```
- Users can only read/write their own data in /users/{userId}
- All other access is denied by default
- Stores encrypted user settings backup
```

### Storage Rules
```
- Users can read all profile images
- Users can only write to their own profile folder
- All other access is denied by default
```

## 🚀 Next Steps to Complete Authentication

### 1. Configure Google Sign-In (REQUIRED)

#### Get SHA-1 Certificate Fingerprint
```bash
cd android
./gradlew signingReport
```

Copy the SHA-1 fingerprint (looks like: `A1:B2:C3:...`)

#### Add to Firebase Console
1. Go to: https://console.firebase.google.com/project/zaya-wellness-2026
2. Click on "Zaya Android" app
3. Scroll to "SHA certificate fingerprints"
4. Click "Add fingerprint"
5. Paste your SHA-1 fingerprint
6. Click "Save"

#### Configure OAuth Consent Screen
1. Go to Google Cloud Console: https://console.cloud.google.com/
2. Select project: "Zaya Wellness App"
3. Navigate to: APIs & Services → OAuth consent screen
4. Fill in:
   - App name: "Zaya"
   - User support email: sajawal0005@gmail.com
   - Developer contact: sajawal0005@gmail.com
5. Add scopes: `email`, `profile`
6. Save and continue

### 2. Implement Google Sign-In in Flutter

The authentication service needs to be created. Here's what needs to be done:

#### Create `lib/services/auth_service.dart`:
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Current user
  User? get currentUser => _auth.currentUser;

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return null;

      // Obtain the auth details
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
```

#### Update `login_screen.dart`:
Replace the `_handleGoogleSignIn` method with actual authentication.

### 3. Test Firebase Connection

Run the app and check Firebase Console to see if:
- User is created in Authentication
- User document is created in Firestore (when you implement backup)

## 📊 Firestore Data Structure

### Recommended Schema

```
/users/{userId}
  - email: string
  - displayName: string
  - photoURL: string
  - createdAt: timestamp
  - lastUpdated: timestamp
  - settings: {
      isPregnancyMode: boolean
      weight: number
      height: number
      notificationsEnabled: boolean
    }
  - encryptedData: string (encrypted Isar backup)
```

## 🔧 Environment Variables

All Firebase configuration is now in:
- `lib/firebase_options.dart` - For Flutter app
- `android/app/google-services.json` - For Android build
- `.firebaserc` - For Firebase CLI

## 📱 Testing

### Local Testing
```bash
flutter run
```

### Production Build
```bash
flutter build apk --release
```

## 🌐 Firebase Console Links

- **Project Home**: https://console.firebase.google.com/project/zaya-wellness-2026
- **Authentication**: https://console.firebase.google.com/project/zaya-wellness-2026/authentication
- **Firestore**: https://console.firebase.google.com/project/zaya-wellness-2026/firestore
- **Storage**: https://console.firebase.google.com/project/zaya-wellness-2026/storage

## 🎯 Implementation Checklist

- [x] Create Firebase project
- [x] Initialize Authentication with Google Sign-In
- [x] Initialize Firestore database
- [x] Initialize Firebase Storage
- [x] Create Android app in Firebase
- [x] Generate google-services.json
- [x] Configure security rules
- [ ] Add SHA-1 certificate to Firebase console
- [ ] Configure OAuth consent screen
- [ ] Implement AuthService in Flutter
- [ ] Update login screen with real authentication
- [ ] Test Google Sign-In flow
- [ ] Implement Firestore backup feature
- [ ] Deploy Firestore and Storage rules

## 🚨 Important Notes

1. **SHA-1 Fingerprint**: You MUST add your SHA-1 fingerprint to Firebase Console for Google Sign-In to work
2. **OAuth Consent**: Configure the OAuth consent screen in Google Cloud Console
3. **Security Rules**: Current rules are secure - users can only access their own data
4. **Backup**: Firestore is configured only for optional encrypted backup - main data stays in Isar

## 📞 Support

If you encounter issues:
1. Check Firebase Console for error messages
2. Verify SHA-1 fingerprint is added correctly
3. Ensure OAuth consent screen is configured
4. Check that google-services.json is in the correct location

---

**Firebase Backend Status**: ✅ **READY FOR DEVELOPMENT**

All backend infrastructure is configured. Complete the Google Sign-In setup steps above to start authenticating users!
