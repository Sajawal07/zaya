import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zaya/core/app_colors.dart';
import 'package:zaya/features/home/presentation/screens/main_layout.dart';
import 'package:zaya/providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo/Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    'assets/images/login.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to Zaya',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Your wellness companion for radiance and life.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  // Implement Google Sign In
                  _handleGoogleSignIn(context, ref);
                },
                icon: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                  height: 24,
                ),
                label: const Text('Continue with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.nudeRose.withOpacity(0.3)),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'By continuing, you agree to our Terms and Privacy Policy',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final authService = ref.read(authServiceProvider);
    
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signing in with Google...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Attempt Google Sign In
      final userCredential = await authService.signInWithGoogle();
      
      if (userCredential == null) {
        // User cancelled the sign-in
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return;
      }

      if (!context.mounted) return;

      // Success - navigate to MainLayout
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      final errorStr = e.toString();
      String message = 'Sign in failed: $errorStr';
      if (errorStr.contains('SocketException') || errorStr.contains('host lookup')) {
        message = 'Please check your internet connection or Private DNS settings and try again.';
      }
      
      // Show error message
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
