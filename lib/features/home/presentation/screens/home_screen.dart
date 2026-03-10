import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zaya/core/app_colors.dart';
import 'package:zaya/features/pregnancy/presentation/screens/pregnancy_home_screen.dart';
import 'package:zaya/providers/user_settings_provider.dart';
import 'package:zaya/features/home/presentation/widgets/cycle_dial_painter.dart';
import 'package:zaya/features/home/presentation/widgets/quick_log_sheet.dart';
import 'package:zaya/providers/cycle_provider.dart';
import 'package:zaya/providers/database_provider.dart';
import 'package:zaya/models/user_metrics.dart';
import 'package:zaya/models/cycle_log.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zaya/features/health/presentation/screens/pcos_analysis_screen.dart';
import 'package:zaya/features/cycle/presentation/widgets/cycle_tracker_widget.dart';
import 'package:zaya/services/notification_service.dart';
import 'package:zaya/providers/sync_provider.dart';
import 'notification_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPregnancyMode = ref.watch(pregnancyModeProvider);
    final cycleAsync = ref.watch(cycleDataProvider);

    if (isPregnancyMode) {
      return const PregnancyHomeScreen();
    }

    return cycleAsync.when(
      data: (info) => _buildCycleView(context, ref, info),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error loading cycle: $e'))),
    );
  }

  Widget _buildCycleView(BuildContext context, WidgetRef ref, CycleInfo info) {
    final int currentDay = info.currentDay;
    const int cycleLength = 28;
    final String phase = info.phase;
    const bool isPregnancyMode = false;
    
    return Scaffold(
      backgroundColor: AppColors.oldLace,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.oldLace,
              elevation: 0,
              floating: true,
              title: Text(
                'Your Cycle',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFF333333)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen()),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (currentDay == 0) ...[
                      _buildSetupCard(context, ref),
                    ] else ...[
                    if (currentDay >= 29) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD47A8E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFD47A8E).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFD47A8E)),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Your period is due! Please log it for accurate tracking.',
                                style: TextStyle(
                                  color: Color(0xFFD47A8E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Circular Tracker Widget
                      CycleTrackerWidget(
                        currentDay: currentDay,
                        periodHistory: info.history,
                        onStartToday: () async {
                          final db = ref.read(databaseServiceProvider);
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final now = DateTime.now();
                            final log = CycleLog()
                              ..userId = user.uid
                              ..date = now
                              ..isPeriodStart = true;
                            await db.saveCycleLog(log);
                            
                            // Also update user metrics for redundancy
                            final metrics = await db.getUserMetrics(user.uid) ?? UserMetrics()..userId = user.uid;
                            metrics.lastPeriodDate = now;
                            await db.saveUserMetrics(metrics);
                            
                            // Notification Sync & Local Batch Scheduling
                            await ref.read(firestoreSyncServiceProvider).syncCycleData(
                              lastPeriodDate: now,
                            );
                            await NotificationService.scheduleCycleSequence(now);

                            ref.invalidate(cycleDataProvider);
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Period started today! Tracking reset.'),
                                  backgroundColor: Color(0xFFD47A8E),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Next Period',
                              '${info.nextPeriodDays} days',
                              Icons.calendar_today_rounded,
                              AppColors.periodRed,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Fertile Window',
                              info.isFertile ? 'Today' : 'In ${currentDay < 10 ? 10 - currentDay : "Soon"} days',
                              Icons.spa_rounded,
                              AppColors.fertileGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Quick Log Button
                    Card(
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const QuickLogSheet(),
                          ).then((_) => ref.invalidate(cycleDataProvider));
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.nudeRose.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: AppColors.nudeRose,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Log Today',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Track flow, mood, and symptoms',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    _buildTipCard(context, phase),
                    
                    const SizedBox(height: 24),

                    // PCOS Analysis Quick Link
                    _buildPcosCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPcosCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
           Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PcosAnalysisScreen()),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              const Icon(Icons.waves_rounded, color: AppColors.nudeRose, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Explore Your Hormonal Profile',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupCard(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 48, color: AppColors.nudeRose),
          const SizedBox(height: 16),
          Text(
            'Welcome to Zaya',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'To start tracking your cycle, please enter the date of your last period.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 60)),
                lastDate: DateTime.now(),
              );
              
              if (date != null) {
                final db = ref.read(databaseServiceProvider);
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final metrics = await db.getUserMetrics(user.uid) ?? UserMetrics()..userId = user.uid;
                  metrics.lastPeriodDate = date;
                  await db.saveUserMetrics(metrics);

                  // Notification Sync & Local Batch Scheduling
                  await ref.read(firestoreSyncServiceProvider).syncCycleData(
                    lastPeriodDate: date,
                  );
                  await NotificationService.scheduleCycleSequence(date);

                  ref.invalidate(cycleDataProvider);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.nudeRose,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Set Last Period Date'),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTipCard(BuildContext context, String phase) {
    String tip;
    switch (phase) {
      case 'Menstrual':
        tip = 'Focus on rest and warm, nourishing foods. Magnesium and iron-rich foods are your best friends right now.';
        break;
      case 'Follicular':
        tip = 'Your energy is rising! Great for trying new recipes and starting new projects.';
        break;
      case 'Ovulation':
        tip = 'Energy is at its peak. Perfect time for socialize and high-intensity workouts.';
        break;
      case 'Luteal':
        tip = 'Switch to gentle movement. Focus on fiber-rich foods to help process hormones.';
        break;
      default:
        tip = 'Keep tracking your daily wellness to get personalized tips!';
    }

    return Card(
      color: AppColors.mistySage.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: AppColors.mistySage, size: 20),
                const SizedBox(width: 8),
                Text('Daily Wellness Tip', style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tip,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
