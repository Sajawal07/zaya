import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/providers/auth_provider.dart';
import 'package:hercycle_bloom/services/account_lifecycle_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hercycle_bloom/features/auth/presentation/screens/login_screen.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── About HerCycle Bloom ─────────────────────────────────────────────────────────────

class AboutHerCycleBloomScreen extends StatelessWidget {
  const AboutHerCycleBloomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: const Text('About HerCycle Bloom'),
        backgroundColor: AppColors.oldLace,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.nudeRose, AppColors.mistySage],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.nudeRose.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'HerCycle Bloom',
              style: GoogleFonts.montserrat(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your Intelligent Women\'s Health Companion',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            _InfoCard(
              icon: Icons.info_outline_rounded,
              color: AppColors.nudeRose,
              title: 'What is HerCycle Bloom?',
              body:
                  'HerCycle Bloom is a comprehensive women\'s health application designed to empower you with insights into your reproductive and hormonal health. From cycle tracking and fertility awareness to PCOS support and guided pregnancy journeys, HerCycle Bloom is your trusted health companion.',
            ),
            const SizedBox(height: 16),
            _InfoCard(
              icon: Icons.auto_awesome_rounded,
              color: const Color(0xFF9C59D1),
              title: 'Powered by AI',
              body:
                  'HerCycle Bloom integrates cutting-edge generative AI to provide personalized, context-aware health coaching. Premium members benefit from unlimited conversations with the AI Health Coach, tailored to their unique cycle and symptom patterns.',
            ),
            const SizedBox(height: 16),
            _InfoCard(
              icon: Icons.security_rounded,
              color: AppColors.fertileGreen,
              title: 'Private by Design',
              body:
                  'Your health data belongs to you. HerCycle Bloom is built with privacy-first principles — your data is never sold, never used for advertising, and encrypted both on-device and in transit.',
            ),
            const SizedBox(height: 16),
            _InfoCard(
              icon: Icons.favorite_border_rounded,
              color: AppColors.pregnancyGold,
              title: 'Our Mission',
              body:
                  'We believe every woman deserves access to clear, compassionate, and accurate health knowledge. HerCycle Bloom bridges the gap between complex medical data and everyday wellness — making women\'s health accessible, understandable, and actionable.',
            ),
            const SizedBox(height: 24),
            Text(
              'Version 1.0.0 (Build 1)',
              style: GoogleFonts.montserrat(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2026 HerCycle Bloom. All rights reserved.',
              style: GoogleFonts.montserrat(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact Support ─────────────────────────────────────────────────────────

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: const Text('Contact Support'),
        backgroundColor: AppColors.oldLace,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.nudeRose.withValues(alpha: 0.2),
                    AppColors.mistySage.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.support_agent_rounded,
                      color: AppColors.nudeRose, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    'We\'re here to help',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our support team typically responds within 24–48 hours on business days.',
                    style: GoogleFonts.montserrat(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'REACH US AT',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.nudeRose,
              ),
            ),
            const SizedBox(height: 12),
            _ContactOption(
              icon: Icons.email_outlined,
              color: AppColors.nudeRose,
              label: 'Email Support',
              value: 'sajawal0005@gmail.com',
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'sajawal0005@gmail.com',
                  queryParameters: {'subject': 'HerCycle Bloom Support Request'},
                );
                try {
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  } else {
                    await Clipboard.setData(const ClipboardData(text: 'sajawal0005@gmail.com'));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email copied: sajawal0005@gmail.com')),
                      );
                    }
                  }
                } catch (_) {
                  await Clipboard.setData(const ClipboardData(text: 'sajawal0005@gmail.com'));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email copied: sajawal0005@gmail.com')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 32),
            Text(
              'HOURS OF OPERATION',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _HoursRow(day: 'Monday – Friday', hours: '9:00 AM – 6:00 PM (PKT)'),
                  const Divider(height: 20),
                  _HoursRow(day: 'Saturday', hours: '10:00 AM – 2:00 PM (PKT)'),
                  const Divider(height: 20),
                  _HoursRow(day: 'Sunday & Public Holidays', hours: 'Closed'),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.montserrat(
                        color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
            const Spacer(),
            Icon(Icons.copy_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String day;
  final String hours;

  const _HoursRow({required this.day, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day,
            style: GoogleFonts.montserrat(
                fontSize: 13, color: AppColors.textPrimary)),
        Text(hours,
            style: GoogleFonts.montserrat(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Report a Problem ────────────────────────────────────────────────────────

class ReportProblemScreen extends ConsumerStatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  ConsumerState<ReportProblemScreen> createState() =>
      _ReportProblemScreenState();
}

class _ReportProblemScreenState extends ConsumerState<ReportProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Bug / App Crash';
  bool _submitted = false;
  bool _submitting = false;

  static const _categories = [
    'Bug / App Crash',
    'Incorrect Prediction',
    'Sync Issue',
    'Missing Data',
    'Payment / Billing',
    'AI Coach Issue',
    'Other',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('problem_reports').add({
        'userId': user?.uid ?? 'anonymous',
        'userEmail': user?.email ?? 'unknown',
        'category': _selectedCategory,
        'subject': _subjectController.text.trim(),
        'description': _descController.text.trim(),
        'appVersion': '1.0.0',
        'platform': 'Android',
        'submittedAt': FieldValue.serverTimestamp(),
        'status': 'open',
      });

      if (mounted) {
        setState(() {
          _submitting = false;
          _submitted = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report. Please try again.\nError: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: const Text('Report a Problem'),
        backgroundColor: AppColors.oldLace,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _submitted ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.fertileGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.fertileGreen, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Report Submitted!',
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you for helping us improve HerCycle Bloom. Our team will review your report and follow up if needed.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  color: AppColors.textSecondary, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.nudeRose,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Help us fix issues faster by describing what happened.',
            style: GoogleFonts.montserrat(
                color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Category
          Text(
            'CATEGORY',
            style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.nudeRose),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c,
                        style: GoogleFonts.montserrat(fontSize: 14))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Subject
          Text(
            'SUBJECT',
            style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.nudeRose),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _subjectController,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Subject is required' : null,
            decoration: InputDecoration(
              hintText: 'Brief description of the issue',
              hintStyle: GoogleFonts.montserrat(color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),

          // Details
          Text(
            'DETAILS',
            style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.nudeRose),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descController,
            maxLines: 5,
            validator: (v) =>
                v == null || v.trim().length < 20
                    ? 'Please provide at least 20 characters'
                    : null,
            decoration: InputDecoration(
              hintText: 'What happened? Steps to reproduce, screens involved…',
              hintStyle: GoogleFonts.montserrat(
                  color: AppColors.textSecondary, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.nudeRose,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _submitting
                ? const AppLoader(size: 22, color: Colors.white)
                : Text('Submit Report',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Delete Account ──────────────────────────────────────────────────────────

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmController = TextEditingController();
  bool _confirmed = false;
  bool _deleting = false;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_confirmed) return;
    setState(() => _deleting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() => _deleting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You must be signed in to delete your account.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final authService = ref.read(authServiceProvider);
      final lifecycle = ref.read(accountLifecycleServiceProvider);
      await lifecycle.deleteAccount(authService);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } on AccountLifecycleException catch (e) {
      debugPrint('Delete account lifecycle error: $e');
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Delete account auth error: ${e.code} ${e.message}');
      if (mounted) {
        setState(() => _deleting = false);
        final msg = e.code == 'requires-recent-login' ||
                e.code == 'reauth-cancelled' ||
                e.code == 'user-mismatch' ||
                e.code == 'missing-google-token'
            ? (e.message ??
                'Please confirm with your Google account (${FirebaseAuth.instance.currentUser?.email ?? 'the same account'}) and tap Delete Account again.')
            : 'Failed to delete account (${e.code}). Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      debugPrint('Delete account failed: $e');
      if (mounted) {
        setState(() => _deleting = false);
        final raw = e.toString();
        final needsReauth = raw.contains('requires-recent-login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              needsReauth
                  ? 'Google needs a fresh confirmation. Tap Delete Account again and complete the Google sign-in prompt.'
                  : 'Failed to delete account. Please try again.\n$e',
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: AppColors.oldLace,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.error, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This action is permanent',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Deleting your account permanently erases your cycle logs, health data, pregnancy data, AI chats, Premium entitlement on this account, and your Firebase login. You will be asked to confirm with Google first. This cannot be undone.',
                          style: GoogleFonts.montserrat(
                              fontSize: 13, height: 1.5, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // What will be deleted
            Text(
              'WHAT WILL BE DELETED',
              style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
                ],
              ),
              child: Column(
                children: const [
                  _DeletionItem('All cycle and menstruation logs'),
                  _DeletionItem('Symptom, mood, and note history'),
                  _DeletionItem('Body metrics and BMI history'),
                  _DeletionItem('Pregnancy tracking data'),
                  _DeletionItem('AI coach conversations (Premium)'),
                  _DeletionItem('Premium entitlement for this account'),
                  _DeletionItem('Account profile and preferences'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Confirmation field
            Text(
              'TYPE "DELETE" TO CONFIRM',
              style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.error),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              onChanged: (v) =>
                  setState(() => _confirmed = v.trim().toUpperCase() == 'DELETE'),
              decoration: InputDecoration(
                hintText: 'Type DELETE',
                hintStyle: GoogleFonts.montserrat(color: AppColors.textSecondary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _confirmed
                        ? AppColors.error
                        : AppColors.textSecondary.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _confirmed
                        ? AppColors.error
                        : AppColors.textSecondary.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 28),

            AnimatedOpacity(
              opacity: _confirmed ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton.icon(
                onPressed: (_confirmed && !_deleting) ? _deleteAccount : null,
                icon: _deleting
                    ? const AppLoader(size: 22, color: Colors.white)
                    : const Icon(Icons.delete_forever_rounded),
                label: Text(
                  _deleting ? 'Deleting…' : 'Delete My Account',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.error,
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DeletionItem extends StatelessWidget {
  final String text;
  const _DeletionItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.remove_circle_outline_rounded,
              color: AppColors.error, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: GoogleFonts.montserrat(
                    fontSize: 13, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
