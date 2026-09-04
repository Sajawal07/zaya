import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/features/pregnancy/presentation/screens/pregnancy_home_screen.dart';
import 'package:hercycle_bloom/providers/user_settings_provider.dart';
import 'package:hercycle_bloom/features/health/presentation/screens/daily_log_screen.dart';
import 'package:hercycle_bloom/providers/cycle_provider.dart';
import 'package:hercycle_bloom/providers/database_provider.dart';
import 'package:hercycle_bloom/models/user_metrics.dart';
import 'package:hercycle_bloom/models/cycle_log.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hercycle_bloom/features/health/presentation/screens/pcos_analysis_screen.dart';
import 'package:hercycle_bloom/features/cycle/presentation/widgets/cycle_tracker_widget.dart';
import 'package:hercycle_bloom/services/notification_service.dart';
import 'package:hercycle_bloom/services/cycle_update_handler.dart';
import 'package:hercycle_bloom/core/cycle_math.dart';
import 'package:hercycle_bloom/providers/sync_provider.dart';
import 'package:hercycle_bloom/providers/premium_provider.dart';
import 'package:hercycle_bloom/features/profile/presentation/screens/premium_paywall_screen.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';
import 'notification_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPregnancyMode = ref.watch(pregnancyModeProvider);
    // Listen to calendar refresh key to trigger cycle data refresh
    // when the user edits period dates from the Calendar screen
    ref.listen<int>(calendarRefreshKeyProvider, (previous, next) {
      if (next != previous) {
        ref.refresh(cycleDataProvider).value;
      }
    });
    final cycleAsync = ref.watch(cycleDataProvider);
    final isPremium = ref.watch(isPremiumProvider);

    if (isPregnancyMode) {
      return const PregnancyHomeScreen();
    }

    return cycleAsync.when(
      data: (info) => _buildCycleView(context, ref, info, isPremium),
      loading: () => const Scaffold(body: AppLoaderCentered()),
      error: (e, s) => Scaffold(body: Center(child: Text('Error loading cycle: $e'))),
    );
  }

  Widget _buildCycleView(BuildContext context, WidgetRef ref, CycleInfo info, bool isPremium) {
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
                          color: const Color(0xFFD47A8E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFD47A8E).withValues(alpha: 0.3)),
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
                        onStartToday: () => _logOrEditPeriodStart(context, ref),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Next Period',
                              info.isLate
                                ? '${info.nextPeriodDays.abs()} days late'
                                : info.nextPeriodDays == 0
                                  ? 'Today'
                                  : '${info.nextPeriodDays} days',
                              Icons.calendar_today_rounded,
                              AppColors.periodRed,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Fertile Window',
                              info.isFertile 
                                ? 'Today' 
                                : info.daysUntilFertile > 0 
                                  ? 'In ${info.daysUntilFertile} days' 
                                  : 'Passed',
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DailyLogScreen()),
                          );
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
                                  color: AppColors.nudeRose.withValues(alpha: 0.1),
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

                    if (!isPremium) ...[
                      const SizedBox(height: 24),
                      _buildHomeAdBanner(context),
                    ],
                    // Clear the floating AI FAB so bottom content is not obscured
                    const SizedBox(height: 150),
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
            'Welcome to HerCycle Bloom',
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
                  ref.read(calendarRefreshKeyProvider.notifier).state++;
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
      color: AppColors.mistySage.withValues(alpha: 0.2),
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

  Widget _buildHomeAdBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.nudeRose.withValues(alpha: 0.05),
            AppColors.pregnancyGold.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.pregnancyGold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pregnancyGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AD',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pregnancyGold,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Enjoying HerCycle Bloom? Go Premium for an ad-free experience, unlimited AI coaching, and deep cycle analytics.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
              );
            },
            child: const Text(
              'Remove Ads & Unlock All Features',
              style: TextStyle(
                color: AppColors.nudeRose,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Log a new period start, or edit the current one.
/// A new period requires ≥24 days from the latest start; closer dates update that entry.
Future<void> _logOrEditPeriodStart(BuildContext context, WidgetRef ref) async {
  final db = ref.read(databaseServiceProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // Clear false period-starts left by older daily-log bugs so edit/create works.
  await db.consolidatePeriodStarts(user.uid);
  if (!context.mounted) return;

  final selectedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now().subtract(const Duration(days: 60)),
    lastDate: DateTime.now(),
    helpText: 'SELECT PERIOD START DATE',
    confirmText: 'LOG PERIOD',
  );
  if (selectedDate == null || !context.mounted) return;

  final normalized = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  final latest = await db.getLatestStartLog(user.uid);

  // Same calendar day already logged → offer to change that date.
  if (latest != null) {
    final latestDay = DateTime(latest.date.year, latest.date.month, latest.date.day);
    final gap = CycleMath.daysBetween(latestDay, normalized).abs();

    if (gap == 0) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Period already logged for this date.'),
          backgroundColor: AppColors.periodRed,
          action: SnackBarAction(
            label: 'Change Date',
            textColor: Colors.white,
            onPressed: () async {
              final newDate = await showDatePicker(
                context: context,
                initialDate: latestDay,
                firstDate: DateTime.now().subtract(const Duration(days: 60)),
                lastDate: DateTime.now(),
              );
              if (newDate == null || !context.mounted) return;
              final next = DateTime(newDate.year, newDate.month, newDate.day);
              if (next == latestDay) return;
              final ok = await _applyPeriodDateUpdate(
                context,
                ref,
                logId: latest.id,
                newDate: next,
                excludeLogId: latest.id,
              );
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Period date updated to ${next.month}/${next.day}/${next.year}.',
                    ),
                    backgroundColor: AppColors.periodRed,
                  ),
                );
              }
            },
          ),
        ),
      );
      return;
    }

    // Gap under minimum cycle length (21 days) -> offer explicit choice dialog
    if (gap < CycleMath.minLength) {
      if (!context.mounted) return;
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Short Cycle or Update Date?'),
          content: Text(
            'Your previous period start was on '
            '${latestDay.month}/${latestDay.day}/${latestDay.year} ($gap days ago).\n\n'
            'Would you like to edit that previous entry or log this as a new short cycle?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'update'),
              child: const Text('Edit Previous Entry'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, 'new'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.periodRed),
              child: const Text('Log as New Cycle', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (choice == 'update' && context.mounted) {
        final ok = await _applyPeriodDateUpdate(
          context,
          ref,
          logId: latest.id,
          newDate: normalized,
          excludeLogId: latest.id,
        );
        if (ok && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Period date updated to ${normalized.month}/${normalized.day}/${normalized.year}.',
              ),
              backgroundColor: AppColors.periodRed,
            ),
          );
        }
        return;
      } else if (choice != 'new') {
        return;
      }
    }
  }


  // ≥24 day gap (or no prior start) → create a new period start.
  final existingForDate = await db.getPeriodStartForDate(user.uid, normalized);
  if (existingForDate != null) {
    // Older history entry on this date — treat as edit of that entry.
    if (!context.mounted) return;
    final ok = await _applyPeriodDateUpdate(
      context,
      ref,
      logId: existingForDate.id,
      newDate: normalized,
      excludeLogId: existingForDate.id,
    );
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Period date set to ${normalized.month}/${normalized.day}/${normalized.year}.',
          ),
          backgroundColor: AppColors.periodRed,
        ),
      );
    }
    return;
  }

  final log = CycleLog()
    ..userId = user.uid
    ..date = normalized
    ..isPeriodStart = true;
  await db.saveCycleLog(log);
  await _syncPeriodStart(ref, user.uid, normalized);

  if (context.mounted) {
    final now = DateTime.now();
    final isToday =
        normalized.year == now.year && normalized.month == now.month && normalized.day == now.day;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isToday
              ? 'Period started today! Tracking reset.'
              : 'Period start logged for ${normalized.month}/${normalized.day}/${normalized.year}.',
        ),
        backgroundColor: const Color(0xFFD47A8E),
      ),
    );
  }
}

Future<bool> _applyPeriodDateUpdate(
  BuildContext context,
  WidgetRef ref, {
  required int logId,
  required DateTime newDate,
  required int excludeLogId,
}) async {
  final db = ref.read(databaseServiceProvider);
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final duplicate = await db.getPeriodStartForDate(user.uid, newDate);
  if (duplicate != null && duplicate.id != excludeLogId) {
    // Another start sits on the target day — move this one by clearing the duplicate flag
    // only if it's a stale clustered entry; otherwise block.
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Period already logged for that date.'),
          backgroundColor: Color(0xFFD47A8E),
        ),
      );
    }
    return false;
  }

  await db.updateCycleLogDate(logId, newDate);
  await db.consolidatePeriodStarts(user.uid);
  await _syncPeriodStart(ref, user.uid, newDate);
  return true;
}

Future<void> _syncPeriodStart(WidgetRef ref, String userId, DateTime periodDate) async {
  await CycleUpdateHandler.onCycleDataChanged(ref, userId);
}

