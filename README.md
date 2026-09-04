# HerCycle Bloom - Wellness & Cycle Tracking App

A Flutter mobile application for cycle tracking, PCOS management, and pregnancy monitoring with AI-powered assistance.

## 🎨 Design Philosophy
**Soft Tech** - The app feels like a wellness journal, not a clinical medical tool.
- Calm, warm, minimal, and feminine aesthetic
- Premium, modern UI with smooth animations
- Material 3 design system

## 🎨 Color Palette
- **Primary (Nude Rose)**: `#E8AAB8` - Main actions
- **Secondary (Misty Sage)**: `#B6C9BB` - PCOS and Nutrition  
- **Accent (Old Lace)**: `#FDF5E6` - Background
- **Period Red**: `#E57373`
- **Fertile Green**: `#81C784`
- **Pregnancy Gold**: `#FFD54F`

## 📝 Typography
- **Headers**: Playfair Display (via Google Fonts)
- **Body Text**: Montserrat (via Google Fonts)

## ✅ Implemented Features (Phase 1)

### Authentication & Onboarding
- ✅ Native Splash Screen with HerCycle Bloom branding
- ✅ 3-Screen Animated Onboarding flow
- ✅ **Google Sign-In** integrated with Firebase Auth
- ✅ AuthService with Riverpod state management

### Core UI Architecture
- ✅ Bottom navigation with 5 tabs (Home, Logs, Nourish, AI, Profile)
- ✅ Material 3 theme with custom colors and typography
- ✅ Responsive layouts with proper spacing

### Home Screen - Cycle Tracking
- ✅ **Circular Progress Ring (Sun Dial)**
  - Displays current cycle day or pregnancy week
  - Phase-based color coding (Period/Fertile/Pregnancy)
  - Custom painted widget with smooth gradients
- ✅ Quick stat cards (Next Period, Fertile Window)
- ✅ Quick Log button with bottom sheet
- ✅ Daily wellness tips card

### Nourish Screen (PCOS Diet Engine)
- ✅ **Daily Nutrition Dashboard**
  - Calorie goal tracking with visual progress
  - Macro nutrient breakdown (Protein, Carbs, Fats)
  - PCOS Tip of the day
- ✅ **Recipe Library**
  - High protein / Low GI recipe cards
  - Detailed recipe view with ingredients & instructions
  - PCOS-specific health benefits highlighted

### Pregnancy Mode (Phase 3)
- ✅ **Dedicated Pregnancy Dashboard**
  - Weekly progress tracker (Day/Week count)
  - "Size of a..." Fruit comparison cards
  - Fetal development highlights
- ✅ **Kick Counter Tool**
  - Session-based kick tracking
  - Live timer and history log
  - Big, easy-to-tap interface
- ✅ **Appointments Tracker**
  - Visual timeline of upcoming visits
  - Color-coded appointment types (Scan, Test, Checkup)
  - Add/Edit functionality (UI)

### Profile Screen
- ✅ User information display (from Google Auth)
- ✅ **Pregnancy Mode toggle**
- ✅ Body metrics section (Weight, Height, BMI)
- ✅ Settings navigation
- ✅ Sign out functionality

### Data & Backend
- ✅ **Firebase Backend Configured** (Auth, Firestore, Storage)
- ✅ Security Rules implemented
- ✅ Isar database setup with code generation
- ✅ CycleLog & UserMetrics data models

## 🚧 To Be Implemented



### Future Enhancements
- [ ] **Data Persistence**
  - Connect LogsScreen to Isar database
  - Connect NourishScreen history to Isar
- [ ] **Notifications**
  - Local reminders for period
  - Ovulation window alerts
  - Meal plan reminders

### Additional Features
- [ ] **Notifications**
  - Local reminders for period
  - Ovulation window alerts
  - Daily wellness tips

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (^3.7.2)
- Firebase project set up (See `FIREBASE_SETUP.md`)
- Android Studio with NDK installed

### Firebase Configuration
Detailed setup instructions are in [FIREBASE_SETUP.md](FIREBASE_SETUP.md).

1. **Add SHA-1 Fingerprint**: Required for Google Sign-In
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Add the SHA-1 to Firebase Console.

2. **Run the app**
   ```bash
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   flutter run
   ```

## 📁 Project Structure
```
lib/
├── main.dart                      # App entry point
├── firebase_options.dart          # Firebase configuration
├── core/
│   ├── app_colors.dart           # Color palette
│   └── app_theme.dart            # Material 3 theme
├── models/
│   ├── cycle_log.dart            # Isar model for daily logs
│   └── user_metrics.dart         # Isar model for body metrics
├── services/
│   └── auth_service.dart         # Firebase Auth service
├── providers/
│   └── auth_provider.dart        # Riverpod providers
├── features/
│   ├── auth/
│   │   └── presentation/screens/ # Login, Splash, Onboarding
│   ├── home/
│   │   └── presentation/
│   │       ├── screens/          # Home Screen & Main Layout
│   │       └── widgets/          # Cycle Dial & Quick Log
│   └── profile/
│       └── presentation/screens/ # Profile Screen
```

## 🔑 Environment Variables
For production, ensure:
- Firebase API keys are configured in `google-services.json`
- Google Gemini API key is set safely (for future AI features)

---

**Built with ❤️ using Flutter and Firebase**
