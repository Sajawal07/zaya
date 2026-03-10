import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zaya/core/app_colors.dart';
import 'package:zaya/features/auth/presentation/screens/login_screen.dart';
import 'package:zaya/providers/auth_provider.dart';
import 'package:zaya/providers/user_settings_provider.dart';
import 'package:zaya/providers/metrics_provider.dart';
import '../widgets/metric_bottom_sheet.dart';
import 'package:zaya/providers/database_provider.dart';
import 'package:zaya/providers/cycle_provider.dart';
import 'package:zaya/models/user_metrics.dart';
import 'package:zaya/features/health/presentation/screens/pcos_analysis_screen.dart';
import 'package:zaya/providers/pregnancy_provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _togglePregnancyMode(BuildContext context, bool value) async {
    if (!value) {
      // confirm turn off
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Turn off Pregnancy Mode?'),
          content: const Text('This will clear your current pregnancy progress.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, true), 
              child: const Text('Turn Off', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await ref.read(userMetricsProvider.notifier).updatePregnancyMode(false);
      }
      return;
    }

    // Turn on: Ask for start date
    final db = ref.read(databaseServiceProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final latestLog = await db.getLatestStartLog(user.uid);
    final lastPeriod = latestLog?.date;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pregnancy Start Date'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('To track your journey, we need the first day of your last period.'),
            const SizedBox(height: 20),
            if (lastPeriod != null)
              ListTile(
                title: const Text('Use previous record'),
                subtitle: Text('Last period started: ${lastPeriod.day}/${lastPeriod.month}/${lastPeriod.year}'),
                leading: const Icon(Icons.history_rounded, color: AppColors.pregnancyGold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.pregnancyGold.withOpacity(0.3)),
                ),
                onTap: () async {
                  await ref.read(userMetricsProvider.notifier).updatePregnancyMode(true, startDate: lastPeriod);
                  if (context.mounted) Navigator.pop(context);
                },
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sorry, no previous data available. Please enter the date manually.',
                        style: TextStyle(fontSize: 12, color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Enter date manually'),
              leading: const Icon(Icons.calendar_today_rounded, color: AppColors.nudeRose),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.nudeRose.withOpacity(0.3)),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 300)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  await ref.read(userMetricsProvider.notifier).updatePregnancyMode(true, startDate: picked);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isPregnancyMode = ref.watch(pregnancyModeProvider);
    final metricsAsync = ref.watch(userMetricsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                
                // User Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.nudeRose.withOpacity(0.2),
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: AppColors.nudeRose,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? 'User',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'No email',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Hormonal Health Section
                Text('Hormonal Health', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.waves_rounded, color: AppColors.nudeRose),
                    title: const Text('Analyze PCOS Patterns'),
                    subtitle: const Text('Understand your hormonal profile'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PcosAnalysisScreen()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
                
                // Health Insights Card (Dynamic)
                metricsAsync.when(
                  data: (metrics) => metrics != null && metrics.weight != null
                      ? _buildHealthInsightCard(context, metrics)
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),
                
                // Mode Toggle
                Text('Tracking Mode', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Pregnancy Mode'),
                        subtitle: const Text('Track your pregnancy journey'),
                        value: isPregnancyMode,
                        onChanged: (value) => _togglePregnancyMode(context, value),
                        activeColor: AppColors.pregnancyGold,
                        secondary: const Icon(Icons.pregnant_woman_rounded),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // Pregnancy History Section (Conditional)
                ref.watch(pregnancyHistoryProvider).when(
                  data: (history) {
                    final pastJourneys = history.where((j) => !j.isActive).toList();
                    if (pastJourneys.isEmpty) return const SizedBox.shrink();
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pregnancy History', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 12),
                        Card(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pastJourneys.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final journey = pastJourneys[index];
                              return ListTile(
                                leading: const Icon(Icons.history_edu_rounded, color: AppColors.mistySage),
                                title: Text('Journey ${pastJourneys.length - index}'),
                                subtitle: Text(
                                  'Started: ${DateFormat('MMM yyyy').format(journey.startDate)}'
                                  '${journey.endDate != null ? ' - Ended: ${DateFormat('MMM yyyy').format(journey.endDate!)}' : ''}'
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () {
                                  // Detail view could be added here
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                
                const SizedBox(height: 24),
                
                // Body Metrics
                Text('Body Metrics', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                metricsAsync.when(
                  data: (metrics) => _buildMetricsCard(context, metrics),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
                
                const SizedBox(height: 32),

                // Data Reset Section
                Text('Data Management', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.history_toggle_off_rounded, color: Colors.orange),
                        title: const Text('Reset Recent Data'),
                        subtitle: const Text('Undo recent logs and period start'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showResetPrompt(context, false),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                        title: const Text('Start Fresh'),
                        subtitle: const Text('Delete all cycle and body metrics data'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showResetPrompt(context, true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Sign Out Button
                OutlinedButton(
                  onPressed: () async {
                    final authService = ref.read(authServiceProvider);
                    try {
                      await authService.signOut();
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
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Sign Out'),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPrompt(BuildContext context, bool isFullReset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isFullReset ? 'Start Fresh?' : 'Reset Recent Data?'),
        content: Text(isFullReset 
          ? 'This will permanently delete ALL your cycle history and body metrics. This cannot be undone.' 
          : 'This will undo your most recent logs (last 7 days). Your older history and metrics will remain intact.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseServiceProvider);
              if (isFullReset) {
                await db.clearAllData();
              } else {
                // Reset last 7 days
                await db.deleteLogsAfter(DateTime.now().subtract(const Duration(days: 7)));
              }
              ref.invalidate(cycleDataProvider);
              ref.invalidate(userMetricsProvider);
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isFullReset ? 'All data cleared' : 'Recent logs reverted')),
                );
              }
            },
            child: Text(
              isFullReset ? 'Delete Everything' : 'Reset Recent', 
              style: TextStyle(color: isFullReset ? AppColors.error : Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCard(BuildContext context, UserMetrics? metrics) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.monitor_weight_outlined),
            title: const Text('Weight'),
            trailing: Text(metrics?.weight != null ? '${metrics!.weight} kg' : '-- kg'),
            onTap: () => _showMetricEditor(context, metrics),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.height_rounded),
            title: const Text('Height'),
            trailing: Text(metrics?.height != null ? '${metrics!.height} cm' : '-- cm'),
            onTap: () => _showMetricEditor(context, metrics),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('BMI'),
            trailing: Text(metrics?.bmi != null && metrics!.bmi > 0 ? metrics.bmi.toStringAsFixed(1) : '--'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInsightCard(BuildContext context, UserMetrics metrics) {
    final bmi = metrics.bmi;
    String condition;
    String advice;
    Color color;

    if (bmi < 18.5) {
      condition = 'Underweight';
      advice = 'Consider a balanced diet with healthy fats. Consult a doctor if you feel fatigued.';
      color = Colors.blue;
    } else if (bmi < 25) {
      condition = 'Normal Range';
      advice = 'You are in a healthy range! Keep up your regular activity and balanced nutrition.';
      color = AppColors.fertileGreen;
    } else if (bmi < 30) {
      condition = 'Overweight';
      advice = 'Focus on low-GI foods and regular exercise. This helps balance hormones if you have PCOS.';
      color = Colors.orange;
    } else {
      condition = 'Obese';
      advice = 'High BMI can be linked to insulin resistance and PCOS symptoms. We recommend consulting a specialist.';
      color = AppColors.periodRed;
    }

    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety_outlined, color: color),
                const SizedBox(width: 8),
                Text(
                  'Condition: $condition',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              advice,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMetricEditor(BuildContext context, UserMetrics? metrics) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MetricBottomSheet(initialMetrics: metrics),
    );
  }
}
