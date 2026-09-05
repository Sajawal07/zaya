import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/app_theme.dart';
import 'core/navigator_key.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/home/presentation/screens/main_layout.dart';
import 'services/notification_service.dart';
import 'shared/widgets/splash_screen.dart';
import 'services/device_step_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Do not preserve native splash — dismiss on first Flutter frame (custom SplashScreen).
  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: HerCycleBloomApp(),
    ),
  );
}

class HerCycleBloomApp extends StatefulWidget {
  const HerCycleBloomApp({super.key});

  @override
  State<HerCycleBloomApp> createState() => _HerCycleBloomAppState();
}

class _HerCycleBloomAppState extends State<HerCycleBloomApp> {
  /// True once Firebase / services are ready AND min splash time elapsed.
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Keep branded splash visible for a beat even if init is fast.
    final minSplash = Future<void>.delayed(const Duration(milliseconds: 1800));
    final init = _initializeApp();
    await Future.wait([minSplash, init]);
    if (mounted) {
      setState(() => _bootstrapped = true);
    }
  }

Future<void> _initializeApp() async {
     await Firebase.initializeApp(
       options: DefaultFirebaseOptions.currentPlatform,
     );
     await NotificationService.initialize();
     final user = FirebaseAuth.instance.currentUser;
     if (user != null) {
       await DeviceStepService.init(user.uid);
     }
   }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'HerCycle Bloom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _bootstrapped ? const _AuthGate() : const SplashScreen(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData && snapshot.data != null) {
          final uid = snapshot.data!.uid;
          // Persist active user UID
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString('active_user_uid', uid);
          });
          // Initialize step service for this user
          DeviceStepService.init(uid);
          return const MainLayout();
        }
        // User logged out — clear step service state
        DeviceStepService.stopListening();
        return const OnboardingScreen();
      },
    );
  }
}
