# Firebase Backend Setup - HerCycle Bloom ✅ COMPLETE

## ✅ What's Been Configured

### Firebase Project
- **Project ID**: `hercycle-bloom-prod`
- **Project Number**: `847475352438`
- **Display Name**: HerCycle Bloom Prod
- **Region**: Asia South (`asia-south1`)

### Services Initialized

#### 1. **Firebase Authentication**
- ✅ Email/Password authentication enabled
- ✅ Google Sign-In configured
- OAuth Brand: "HerCycle Bloom"
- Support Email: sajawal0005@gmail.com

#### 2. **Cloud Firestore Database**
- ✅ Database: `(default)`
- ✅ Location: `asia-south1`
- ✅ Security rules configured for user data isolation

#### 3. **Firebase Storage**
- ✅ Storage bucket: `hercycle-bloom-prod.firebasestorage.app`
- ✅ Security rules configured for user profile images

### Android App Registered
- **App ID**: `1:847475352438:android:0c4602eb59cde9ed4b9057`
- **Package Name**: `com.hercyclebloom.app`
- **Display Name**: HerCycle Bloom Android
- ✅ `android/app/google-services.json` generated and saved

### iOS App Registered
- **App ID**: `1:847475352438:ios:0c57dde64774df684b9057`
- **Bundle ID**: `com.hercyclebloom.app`
- **Display Name**: HerCycle Bloom iOS
- ✅ `ios/Runner/GoogleService-Info.plist` generated and saved

## 📁 Configuration Files

| File | Purpose |
|---|---|
| `.firebaserc` | Firebase project alias (`hercycle-bloom-prod`) |
| `firebase.json` | Firebase services config (Firestore, Auth, Hosting) |
| `firestore.rules` | Firestore security rules |
| `storage.rules` | Storage security rules |
| `android/app/google-services.json` | Android SDK config (new project) |
| `ios/Runner/GoogleService-Info.plist` | iOS SDK config (new project) |
| `lib/firebase_options.dart` | Flutter Firebase options (updated) |

## 🔒 Security Rules

### Firestore Rules
```
- Users can only read/write their own data in /users/{userId}
- All other access is denied by default
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

Copy the SHA-1 fingerprint and add it to the Firebase Console:
1. Go to: https://console.firebase.google.com/project/hercycle-bloom-prod
2. Click on the Android app → **SHA certificate fingerprints**
3. Click **Add fingerprint** → Paste → **Save**

#### Configure OAuth Consent Screen
1. Go to: https://console.cloud.google.com/
2. Select project: `hercycle-bloom-prod`
3. Navigate to: **APIs & Services → OAuth consent screen**
4. Fill in:
   - App name: "HerCycle Bloom"
   - User support email: sajawal0005@gmail.com
5. Add scopes: `email`, `profile`
6. Save and continue

### 2. Enable Auth Providers in Console
1. Go to: https://console.firebase.google.com/project/hercycle-bloom-prod/authentication/providers
2. Enable **Email/Password**
3. Enable **Google Sign-In**

### 3. Test Firebase Connection

```bash
flutter run
```

Check Firebase Console to see if:
- User is created in Authentication
- User document is created in Firestore

## 📊 Firestore Data Structure

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

## 🌐 Firebase Console Links

- **Project Home**: https://console.firebase.google.com/project/hercycle-bloom-prod
- **Authentication**: https://console.firebase.google.com/project/hercycle-bloom-prod/authentication
- **Firestore**: https://console.firebase.google.com/project/hercycle-bloom-prod/firestore
- **Storage**: https://console.firebase.google.com/project/hercycle-bloom-prod/storage

## 🎯 Implementation Checklist

- [x] Create Firebase project (`hercycle-bloom-prod`)
- [x] Register Android app (`com.hercyclebloom.app`)
- [x] Register iOS app (`com.hercyclebloom.app`)
- [x] Download & save `google-services.json`
- [x] Download & save `GoogleService-Info.plist`
- [x] Update `lib/firebase_options.dart` with new app IDs
- [x] Verify `.firebaserc` points to `hercycle-bloom-prod`
- [x] Verify no `zaya-wellness-2026` or `Zaya` references in backend configs
- [x] Add SHA-1 certificate fingerprint in Firebase Console (`2F:A8:5B:D3:EE:38:FD:95:85:E7:8B:CB:7B:CB:9D:33:0A:EC:46:02`)
- [x] Configure OAuth consent screen in Google Cloud Console (HerCycle Bloom)
- [x] Enable Email/Password + Google Sign-In in Firebase Console
- [ ] Test Google Sign-In flow with `flutter run`
- [x] Deploy Firestore and Storage rules (`firebase deploy --only firestore:rules,storage`)

## 🚨 Important Notes

1. **SHA-1 Fingerprint**: You MUST add your SHA-1 fingerprint to Firebase Console for Google Sign-In to work on Android.
2. **OAuth Consent**: Configure the OAuth consent screen in Google Cloud Console before Google Sign-In works.
3. **Auth Providers**: Must be manually enabled in the Firebase Console (Email/Password & Google).
4. **New Project = Empty Data**: This is a fresh project. Any previous data from `zaya-wellness-2026` is NOT migrated.

## 📞 Support

If you encounter issues:
1. Check Firebase Console for error messages
2. Verify SHA-1 fingerprint is added correctly
3. Ensure OAuth consent screen is configured
4. Check that `google-services.json` is in `android/app/`

---

**Firebase Backend Status**: ✅ **READY FOR DEVELOPMENT**

All backend infrastructure is configured and pointing to `hercycle-bloom-prod`. Complete the manual steps above (SHA-1, OAuth consent, Auth providers) to enable authentication.
