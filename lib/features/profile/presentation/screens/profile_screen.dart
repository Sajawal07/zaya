import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/features/auth/presentation/screens/login_screen.dart';
import 'package:hercycle_bloom/features/home/presentation/screens/main_layout.dart';
import 'package:hercycle_bloom/providers/auth_provider.dart';
import 'package:hercycle_bloom/providers/metrics_provider.dart';
import 'package:hercycle_bloom/providers/cycle_provider.dart';
import 'package:hercycle_bloom/providers/health_analytics_provider.dart';
import 'package:hercycle_bloom/providers/pregnancy_provider.dart';
import 'package:hercycle_bloom/providers/premium_provider.dart';
import 'package:hercycle_bloom/providers/database_provider.dart';
import 'package:hercycle_bloom/providers/user_settings_provider.dart';
import 'package:hercycle_bloom/providers/wellness_provider.dart';
import 'package:hercycle_bloom/providers/nutrition_provider.dart';
import 'package:hercycle_bloom/providers/pcos_provider.dart';
import 'package:hercycle_bloom/providers/ai_provider.dart';
import 'package:hercycle_bloom/services/account_lifecycle_service.dart';
import 'package:hercycle_bloom/features/health/presentation/screens/pcos_analysis_screen.dart';
import 'package:hercycle_bloom/models/user_metrics.dart';
import 'package:intl/intl.dart';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_profile_screen.dart';
import 'notification_preferences_screen.dart';
import 'how_to_use_screen.dart';
import 'faqs_screen.dart';
import 'legal_screens.dart';
import 'support_screens.dart';
import '../widgets/metric_bottom_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // ──────────────────────────────────────────────────────────────────────────
  // Pregnancy Mode Toggle
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _togglePregnancyMode(BuildContext context, bool value) async {
    if (!value) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Turn off Pregnancy Mode?',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
          content: const Text(
              'This will clear your current pregnancy progress and return to cycle tracking.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Turn Off',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await ref.read(userMetricsProvider.notifier).updatePregnancyMode(false);
      }
      return;
    }

    final db = ref.read(databaseServiceProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final latestLog = await db.getLatestStartLog(user.uid);
    final lastPeriod = latestLog?.date;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Pregnancy Start Date',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'To track your journey, we need the first day of your last period.'),
            const SizedBox(height: 20),
            if (lastPeriod != null)
              ListTile(
                title: const Text('Use previous record'),
                subtitle: Text(
                    'Last period: ${lastPeriod.day}/${lastPeriod.month}/${lastPeriod.year}'),
                leading: const Icon(Icons.history_rounded,
                    color: AppColors.pregnancyGold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      BorderSide(color: AppColors.pregnancyGold.withValues(alpha: 0.3)),
                ),
                onTap: () async {
                  await ref
                      .read(userMetricsProvider.notifier)
                      .updatePregnancyMode(true, startDate: lastPeriod);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No previous data available. Please enter the date manually.',
                        style: TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Enter date manually'),
              leading: const Icon(Icons.calendar_today_rounded,
                  color: AppColors.nudeRose),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.nudeRose.withValues(alpha: 0.3)),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: DateTime.now(),
                  firstDate:
                      DateTime.now().subtract(const Duration(days: 300)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  await ref
                      .read(userMetricsProvider.notifier)
                      .updatePregnancyMode(true, startDate: picked);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Data Reset
  // ──────────────────────────────────────────────────────────────────────────

  void _showResetPrompt(BuildContext context, bool isFullReset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isFullReset ? 'Start Fresh?' : 'Reset Recent Data?'),
        content: Text(isFullReset
            ? 'This will permanently delete ALL your cycle history, health logs, and body metrics for this account. Your Google login and Premium access will remain. This cannot be undone.'
            : 'This will undo your most recent logs (last 7 days). Your older history and metrics will remain intact.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                if (ctx.mounted) Navigator.pop(ctx);
                return;
              }

              // Close dialog first so we can show progress / errors on the screen.
              if (ctx.mounted) Navigator.pop(ctx);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(color: AppColors.nudeRose),
                ),
              );

              try {
                final lifecycle = ref.read(accountLifecycleServiceProvider);
                if (isFullReset) {
                  await lifecycle.startFresh(user.uid);
                } else {
                  await lifecycle.resetRecentData(user.uid);
                }

                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop(); // progress
                  if (isFullReset) {
                    // Fresh-install experience while staying signed in + Premium.
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MainLayout(),
                      ),
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        'All health data cleared. Set up your profile to begin again. Premium is unchanged.',
                      ),
                      duration: Duration(seconds: 5),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Recent logs reverted'),
                    ));
                  }
                }
              } catch (e) {
                debugPrint('Reset/StartFresh failed: $e');
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop(); // progress
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      isFullReset
                          ? 'Could not start fresh. Please try again.\n$e'
                          : 'Could not reset recent data. Please try again.\n$e',
                    ),
                    backgroundColor: AppColors.error,
                    duration: const Duration(seconds: 5),
                  ));
                }
              }
            },
            child: Text(
              isFullReset ? 'Delete Everything' : 'Reset Recent',
              style: TextStyle(
                  color: isFullReset ? AppColors.error : Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isPregnancyMode = ref.watch(pregnancyModeProvider);
    final metricsAsync = ref.watch(userMetricsProvider);

    return Scaffold(
      backgroundColor: AppColors.oldLace,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Text(
                  'Profile',
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // ── User Card ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: _UserHeaderCard(user: user),
              ),
            ),

            // ── ACCOUNT & PERSONAL DATA ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
                child: _SectionHeader(
                  label: 'Account & Personal Data',
                  icon: Icons.manage_accounts_rounded,
                  color: AppColors.nudeRose,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ProfileCard(children: [
                  _ProfileTile(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.nudeRose,
                    title: 'Edit Profile',
                    subtitle: 'Name, age, height, weight',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ),
                  ),
                  _Divider(),
                  metricsAsync.when(
                    data: (m) => _ProfileTile(
                      icon: Icons.calculate_outlined,
                      iconColor: m != null && m.bmi > 0
                          ? _bmiColor(m.bmi)
                          : AppColors.textSecondary,
                      title: 'BMI & Body Metrics',
                      subtitle: m != null && m.bmi > 0
                          ? 'BMI: ${m.bmi.toStringAsFixed(1)} · ${_bmiLabel(m.bmi)}'
                          : 'Tap to update your measurements',
                      onTap: () => _showMetricEditor(context, m),
                    ),
                    loading: () => _ProfileTile(
                      icon: Icons.calculate_outlined,
                      iconColor: AppColors.textSecondary,
                      title: 'BMI & Body Metrics',
                      onTap: () => _showMetricEditor(context, null),
                    ),
                    error: (_, __) => _ProfileTile(
                      icon: Icons.calculate_outlined,
                      iconColor: AppColors.textSecondary,
                      title: 'BMI & Body Metrics',
                      onTap: () => _showMetricEditor(context, null),
                    ),
                  ),
                  _Divider(),
                  _ProfileTile(
                    icon: Icons.child_care_rounded,
                    iconColor: AppColors.pregnancyGold,
                    title: 'Pregnancy Mode',
                    subtitle: isPregnancyMode ? 'Active — tracking your journey' : 'Off — cycle tracking mode',
                    trailing: Switch.adaptive(
                      value: isPregnancyMode,
                      onChanged: (v) => _togglePregnancyMode(context, v),
                      activeColor: AppColors.pregnancyGold,
                    ),
                    onTap: () => _togglePregnancyMode(context, !isPregnancyMode),
                  ),
                  _Divider(),
                  _ProfileTile(
                    icon: Icons.notifications_outlined,
                    iconColor: const Color(0xFF9C59D1),
                    title: 'Notification Preferences',
                    subtitle: 'Manage reminders and alerts',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationPreferencesScreen()),
                    ),
                  ),
                  _Divider(),
                ]),
              ),
            ),

            // ── Hormonal Health ───────────────────────────────────────────────
            // Single, canonical entry point into the Hormonal Profile / PCOS
            // analysis. The duplicate "Analyze PCOS Patterns" card that used to
            // live here was removed to avoid redundancy with the Today screen.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ProfileTile(
                  icon: Icons.waves_rounded,
                  iconColor: AppColors.nudeRose,
                  title: 'View Hormonal Profile',
                  subtitle: 'Your hormonal profile & PCOS insights',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PcosAnalysisScreen()),
                  ),
                ),
              ),
            ),

            // ── Pregnancy History ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: ref.watch(pregnancyHistoryProvider).when(
                    data: (history) {
                      final past = history.where((j) => !j.isActive).toList();
                      if (past.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              label: 'Pregnancy History',
                              icon: Icons.history_edu_rounded,
                              color: AppColors.pregnancyGold,
                            ),
                            const SizedBox(height: 10),
                            _ProfileCard(
                              children: past.asMap().entries.map((e) {
                                final idx = e.key;
                                final j = e.value;
                                return Column(
                                  children: [
                                    if (idx > 0) _Divider(),
                                    _ProfileTile(
                                      icon: Icons.history_edu_rounded,
                                      iconColor: AppColors.mistySage,
                                      title:
                                          'Journey ${past.length - idx}',
                                      subtitle:
                                          'Started: ${DateFormat('MMM yyyy').format(j.startDate)}'
                                          '${j.endDate != null ? ' – Ended: ${DateFormat('MMM yyyy').format(j.endDate!)}' : ''}',
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
            ),

            // ── SUPPORT & GUIDANCE ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
                child: _SectionHeader(
                  label: 'Support & Guidance',
                  icon: Icons.help_outline_rounded,
                  color: const Color(0xFF5C6BC0),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ProfileCard(children: [
                  _ProfileTile(
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFF5C6BC0),
                    title: 'How to Use the App',
                    subtitle: 'Feature guides and onboarding',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HowToUseScreen()),
                    ),
                  ),
                  _Divider(),
                  _ProfileTile(
                    icon: Icons.quiz_outlined,
                    iconColor: const Color(0xFF29B6F6),
                    title: 'FAQs',
                    subtitle: 'Common questions answered',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FaqsScreen()),
                    ),
                  ),
                ]),
              ),
            ),

            // ── LEGAL & POLICIES ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
                child: _SectionHeader(
                  label: 'Legal & Policies',
                  icon: Icons.balance_rounded,
                  color: AppColors.fertileGreen,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ProfileCard(children: [
                  _ProfileTile(
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.fertileGreen,
                    title: 'Privacy Policy',
                    subtitle: 'How your data is collected and protected',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen()),
                    ),
                  ),
                  _Divider(),
                  _ProfileTile(
                    icon: Icons.gavel_rounded,
                    iconColor: AppColors.nudeRose,
                    title: 'Terms & Conditions',
                    subtitle: 'Usage rules and subscription terms',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TermsConditionsScreen()),
                    ),
                  ),
                  _Divider(),
                  _ProfileTile(
                    icon: Icons.local_hospital_outlined,
                    iconColor: AppColors.periodRed,
                    title: 'Medical Disclaimer',
                    subtitle: 'HerCycle Bloom is not a substitute for medical advice',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MedicalDisclaimerScreen()),
                    ),
                  ),
                ]),
              ),
            ),

            // ── APP INFORMATION ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
                child: _SectionHeader(
                  label: 'App Information',
                  icon: Icons.info_outline_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ProfileCard(children: [
                  _ProfileTile(
                    icon: Icons.share_rounded,
                    iconColor: AppColors.nudeRose,
                    title: 'Share App',
                    subtitle: 'Spread the word with friends & family',
                    onTap: () async {
                      await Share.share(
                        '🌸 Track your period, symptoms, and pregnancy with HerCycle Bloom! Download now on Google Play Store:\nhttps://play.google.com/store/apps/details?id=com.hercyclebloom.app',
                        subject: 'HerCycle Bloom App',
                      );
                    },
                  ),
                  _Divider(),
                  _ProfileTile(
                    icon: Icons.star_rate_rounded,
                    iconColor: const Color(0xFFFFB300),
                    title: 'Rate My App',
                    subtitle: 'Support us with a 5-star review',
                    onTap: () async {
                      const packageName = 'com.hercyclebloom.app';
                      final marketUri = Uri.parse('market://details?id=$packageName');
                      final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');
                      try {
                        if (await canLaunchUrl(marketUri)) {
                          await launchUrl(marketUri, mode: LaunchMode.externalApplication);
                        } else if (await canLaunchUrl(webUri)) {
                          await launchUrl(webUri, mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open Play Store rating page.')),
                            );
                          }
                        }
                      } catch (_) {
                        if (await canLaunchUrl(webUri)) {
                          await launchUrl(webUri, mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                  ),
                  _Divider(),
                  _ProfileTile(
                    icon: Icons.favorite_rounded,
                    iconColor: AppColors.nudeRose,
                    title: 'About HerCycle Bloom',
                    subtitle: 'Mission, story, and capabilities',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutHerCycleBloomScreen()),
                    ),
                  ),
                  _Divider(),
                  _ProfileTile(
                    icon: Icons.tag_rounded,
                    iconColor: AppColors.textSecondary,
                    title: 'App Version',
                    subtitle: 'v1.0.0 (Build 1)',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mistySage.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('v1.0.0',
                          style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary)),
                    ),
                  ),
                  _Divider(),
                  _ProfileTile(
                    icon: Icons.support_agent_rounded,
                    iconColor: const Color(0xFF5C6BC0),
                    title: 'Contact Support',
                    subtitle: 'Get help from our team',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ContactSupportScreen()),
                    ),
                  ),
                  _Divider(),
                  _ProfileTile(
                    icon: Icons.bug_report_outlined,
                    iconColor: Colors.orange,
                    title: 'Report a Problem',
                    subtitle: 'Send feedback or bug reports',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ReportProblemScreen()),
                    ),
                  ),
                ]),
              ),
            ),

            // ── Data Management ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
                child: _SectionHeader(
                  label: 'Data Management',
                  icon: Icons.storage_rounded,
                  color: Colors.orange,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ProfileCard(children: [
                  _ProfileTile(
                    icon: Icons.history_toggle_off_rounded,
                    iconColor: Colors.orange,
                    title: 'Reset Recent Data',
                    subtitle: 'Undo logs from the last 7 days',
                    onTap: () => _showResetPrompt(context, false),
                  ),
                  _Divider(),
                  _ProfileTile(
                    icon: Icons.delete_sweep_outlined,
                    iconColor: AppColors.error,
                    title: 'Start Fresh',
                    subtitle: 'Erase all health data; keep login & Premium',
                    onTap: () => _showResetPrompt(context, true),
                  ),
                  _Divider(),
                  _ProfileTile(
                    icon: Icons.delete_forever_rounded,
                    iconColor: AppColors.error,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete all data and account',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DeleteAccountScreen()),
                    ),
                  ),
                ]),
              ),
            ),

            // ── Sign Out ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final authService = ref.read(authServiceProvider);
                    try {
                      await authService.signOut();

                      // Invalidate all user-specific providers to clear in-memory state
                      ref.invalidate(userMetricsProvider);
                      ref.invalidate(wellnessProvider);
                      ref.invalidate(nutritionProvider);
                      ref.invalidate(cycleDataProvider);
                      ref.invalidate(healthAnalyticsProvider);
                      ref.invalidate(databaseServiceProvider);
                      ref.invalidate(isPremiumProvider);
                      ref.invalidate(remotePremiumFlagProvider);
                      ref.invalidate(pregnancyModeProvider);
                      ref.invalidate(activePregnancyProvider);
                      ref.invalidate(pregnancyHistoryProvider);
                      ref.invalidate(pcosProvider);
                      ref.invalidate(chatMessagesProvider);

                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sign out failed: ${e.toString()}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: Text(
                    'Sign Out',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return AppColors.fertileGreen;
    if (bmi < 30) return Colors.orange;
    return AppColors.periodRed;
  }

  String _bmiLabel(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  void _showMetricEditor(BuildContext context, UserMetrics? metrics) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MetricBottomSheet(initialMetrics: metrics),
    );
  }
}

// ─── Sub-Widgets ──────────────────────────────────────────────────────────────

class _UserHeaderCard extends StatelessWidget {
  final User? user;
  const _UserHeaderCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.nudeRose.withValues(alpha: 0.15),
            backgroundImage:
                user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                ? const Icon(Icons.person, size: 32, color: AppColors.nudeRose)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Welcome',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'No email linked',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SectionHeader(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 15),
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final List<Widget> children;
  const _ProfileCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(children: children),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: GoogleFonts.montserrat(
                  fontSize: 12, color: AppColors.textSecondary),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 20)
              : null),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 70, endIndent: 18);
}