import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/features/profile/presentation/screens/premium_paywall_screen.dart';
import 'package:hercycle_bloom/providers/premium_provider.dart';
import 'daily_log_screen.dart';
import 'health_conditions_screen.dart';
import 'lab_reports_screen.dart';
import 'medication_reminders_screen.dart';
import 'pcos_analysis_screen.dart';
import 'physical_metrics_screen.dart';

class HealthHubScreen extends ConsumerWidget {
  const HealthHubScreen({super.key});

  void _openOrPaywall(BuildContext context, bool isPremium, Widget screen) {
    if (isPremium) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Hub',
                      style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Manage your daily wellness and medical records',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Free ──
                  _HubCard(
                    title: 'Daily Wellness Log',
                    subtitle: 'Track symptoms, mood, and lifestyle',
                    icon: Icons.edit_note_rounded,
                    color: AppColors.nudeRose,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DailyLogScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _HubCard(
                    title: 'Health Conditions',
                    subtitle: 'PMDD, Endometriosis & more',
                    icon: Icons.health_and_safety_rounded,
                    color: const Color(0xFFF44336),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HealthConditionsScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _HubCard(
                    title: 'Medication & Reminders',
                    subtitle: 'Supplements and prescriptions',
                    icon: Icons.medication_rounded,
                    color: const Color(0xFF4A9373),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MedicationRemindersScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _HubCard(
                    title: 'Physical Metrics',
                    subtitle: 'Track BBT and cervical mucus',
                    icon: Icons.thermostat_auto_rounded,
                    color: const Color(0xFFE57373),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PhysicalMetricsScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Premium ──
                  _HubCard(
                    title: 'Hormonal Profile',
                    subtitle: isPremium
                        ? 'Analyze symptoms and get guidance'
                        : 'Premium — deep PCOS / hormone analysis',
                    icon: Icons.waves_rounded,
                    color: const Color(0xFF9C59D1),
                    isPremiumLocked: !isPremium,
                    onTap: () => _openOrPaywall(
                      context,
                      isPremium,
                      const PcosAnalysisScreen(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _HubCard(
                    title: 'Lab & Medical Reports',
                    subtitle: isPremium
                        ? 'Blood work and test results'
                        : 'Premium — store & review lab reports',
                    icon: Icons.biotech_outlined,
                    color: const Color(0xFF5C6BC0),
                    isPremiumLocked: !isPremium,
                    onTap: () => _openOrPaywall(
                      context,
                      isPremium,
                      const LabReportsScreen(),
                    ),
                  ),
                ]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPremiumLocked;

  const _HubCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPremiumLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isPremiumLocked) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.lock_rounded,
                            size: 14, color: AppColors.pregnancyGold),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isPremiumLocked
                  ? Icons.workspace_premium_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isPremiumLocked
                  ? AppColors.pregnancyGold
                  : color.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
