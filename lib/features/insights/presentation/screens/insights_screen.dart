import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_mode.dart';
import '../../../../providers/cycle_provider.dart';
import '../../../../providers/nutrition_provider.dart';
import '../../../../providers/metrics_provider.dart';
import 'package:hercycle_bloom/providers/premium_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../providers/health_analytics_provider.dart';
import 'package:hercycle_bloom/shared/widgets/empty_state.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);
    return mode == AppMode.pregnancy
        ? const _PregnancyInsights()
        : const _CycleInsights();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CYCLE INSIGHTS
// ─────────────────────────────────────────────────────────────────────────────

class _CycleInsights extends ConsumerWidget {
  const _CycleInsights();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycleInfoAsync = ref.watch(cycleDataProvider);
    final nutritionState = ref.watch(nutritionProvider);
    final isPremium = ref.watch(isPremiumProvider);
    
    return cycleInfoAsync.when(
      loading: () => const Scaffold(body: AppLoaderCentered()),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (cycleInfo) {
        final historyPaths = cycleInfo.history;
        List<double> lengths = [];
        
        // Compute cycle lengths from history dates
        // history is sorted latest first (since periodLogs are usually newest first)
        for (int i = 0; i < historyPaths.length - 1; i++) {
          final curr = historyPaths[i]['date'] as DateTime;
          final prev = historyPaths[i + 1]['date'] as DateTime;
          lengths.add(curr.difference(prev).inDays.toDouble());
        }
        
        final avgLength = lengths.isEmpty
            ? 28.0
            : lengths.reduce((a, b) => a + b) / lengths.length;
        final regularity = _regularity(lengths);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Header ────────────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Insights',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const Text('Your patterns, decoded',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),

                // ── Health Brain Insights ───────────────────────────────────────
                SliverPadding(
                   padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                   sliver: SliverToBoxAdapter(
                     child: _HealthBrainInsightCard(),
                   ),
                ),

                // ── Health Metrics Row ───────────────────────────────────────────
                SliverPadding(
                   padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                   sliver: ref.watch(userMetricsProvider).when(
                    data: (m) => SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle('Daily Goals & Metrics'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _StatCard(label: 'BMI', value: m?.bmi.toStringAsFixed(1) ?? '—', icon: Icons.monitor_weight_outlined, color: const Color(0xFF64B5F6))),
                              const SizedBox(width: 12),
                              Expanded(child: _StatCard(label: 'Daily Goal', value: '${m?.dailyCalorieGoal.round() ?? '—'}', icon: Icons.bolt_rounded, color: const Color(0xFFF06292))),
                              const SizedBox(width: 12),
                              Expanded(child: _StatCard(label: 'BMR', value: '${m?.bmr.round() ?? '—'}', icon: Icons.psychology_outlined, color: const Color(0xFFFFB74D))),
                            ],
                          ),
                          if (m?.calorieGoalNote != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.nudeRose.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.nudeRose.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.nudeRose),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      m!.calorieGoalNote!,
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                     loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                     error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                   ),
                ),
 
                // ── Wellness Matrix Radar ───────────────────────────────────
                SliverPadding(
                   padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                   sliver: SliverToBoxAdapter(
                     child: _WellnessRadarChart(),
                   ),
                ),
 
                // ── Weight Trend ─────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Weight Trend'),
                        const SizedBox(height: 12),
                        _WeightTrendChart(),
                      ],
                    ),
                  ),
                ),

                // ── Cycle Stats Row ───────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Cycle Analysis'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _StatCard(label: 'Avg Cycle', value: '${avgLength.round()} days', icon: Icons.loop_rounded, color: AppColors.nudeRose)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PremiumFeatureLock(
                                isPremium: isPremium,
                                child: _StatCard(label: 'Regularity', value: regularity, icon: Icons.show_chart_rounded, color: AppColors.fertileGreen),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: _StatCard(label: 'History logs', value: '${historyPaths.length}', icon: Icons.history_rounded, color: AppColors.mistySage)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Nutrition Score Trend ─────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: const _SectionTitle('Hormone Nutrition Score'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: _PremiumFeatureLock(
                      isPremium: isPremium,
                      featureName: 'Nutrition Scoring',
                      child: _NutritionTrendChart(nutrition: nutritionState),
                    ),
                  ),
                ),

                // ── Cycle Regularity Bar ──────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  sliver: SliverToBoxAdapter(child: const _SectionTitle('Cycle Length History')),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: _PremiumFeatureLock(
                      isPremium: isPremium,
                      featureName: 'Cycle History',
                      child: _CycleLengthChart(cycles: lengths),
                    ),
                  ),
                ),

                // ── Health Patterns ───────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  sliver: SliverToBoxAdapter(child: const _SectionTitle('Pattern Highlights')),
                ),
                SliverPadding(
                   padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                   sliver: SliverToBoxAdapter(
                     child: _PatternHighlights(cyclesTracked: lengths.length),
                   ),
                 ),

                // Clear the floating AI FAB so bottom content is not obscured
                const SliverToBoxAdapter(child: SizedBox(height: 150)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _regularity(List<double> lengths) {
    if (lengths.length < 2) return 'Tracking…';
    final mean = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance = lengths.map((l) => (l - mean) * (l - mean)).reduce((a, b) => a + b) / lengths.length;
    final sd = variance < 0 ? 0.0 : variance.isNaN ? 0.0 : _sqrt(variance);
    if (sd <= 2) return 'Regular';
    if (sd <= 5) return 'Slightly variable';
    return 'Irregular';
  }

  double _sqrt(double x) {
    double guess = x / 2;
    for (int i = 0; i < 20; i++) guess = (guess + x / guess) / 2;
    return guess;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREGNANCY INSIGHTS
// ─────────────────────────────────────────────────────────────────────────────

class _PregnancyInsights extends ConsumerWidget {
  const _PregnancyInsights();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(userMetricsProvider).value;
    final startDate = metrics?.lastPeriodDate;
    final now = DateTime.now();
    final week = startDate != null ? (now.difference(startDate).inDays ~/ 7) : 0;
    final daysLeft = startDate != null
        ? startDate.add(const Duration(days: 280)).difference(now).inDays
        : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Insights',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Text('Your pregnancy journey, visualized',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(child: _StatCard(label: 'Current Week', value: 'Week $week', icon: Icons.pregnant_woman_rounded, color: AppColors.pregnancyGold)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Days to Due', value: '$daysLeft days', icon: Icons.timer_outlined, color: const Color(0xFF4A9373))),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(label: 'Trimester', value: _trimester(week), icon: Icons.spa_rounded, color: AppColors.nudeRose)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              sliver: SliverToBoxAdapter(child: _SectionTitle('Progress Through Pregnancy')),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              sliver: SliverToBoxAdapter(child: _PregnancyProgressBar(week: week)),
            ),

            // Clear the floating AI FAB so bottom content is not obscured
            const SliverToBoxAdapter(child: SizedBox(height: 150)),
          ],
        ),
      ),
    );
  }

  String _trimester(int week) {
    if (week <= 13) return '1st';
    if (week <= 26) return '2nd';
    return '3rd';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _NutritionTrendChart extends StatelessWidget {
  final NutritionState nutrition;
  const _NutritionTrendChart({required this.nutrition});

  @override
  Widget build(BuildContext context) {
    // Mock 7-day scores — replace with real daily score persistence
    final scores = [6.2, 7.1, 6.8, 8.0, 7.4, 7.9, nutrition.summary?.dailyScore ?? 7.5];
    final maxScore = 10.0;

     return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Bars scale to the available height; reserve fixed room for the
          // day labels so nothing overflows (BOTTOM OVERFLOWED by N px).
          const double labelSpace = 26.0;
          final double barMax = (constraints.maxHeight - labelSpace).clamp(8.0, double.infinity);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(scores.length, (i) {
              final h = (scores[i] / maxScore) * barMax;
              final isToday = i == scores.length - 1;
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isToday)
                      Text(scores[i].toStringAsFixed(1),
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.nudeRose)),
                    const SizedBox(height: 2),
                    Container(
                      height: h,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.nudeRose : AppColors.nudeRose.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(['M', 'T', 'W', 'T', 'F', 'S', 'T'][i],
                        style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _CycleLengthChart extends StatelessWidget {
  final List<double> cycles;
  const _CycleLengthChart({required this.cycles});

  // Normal cycle length range
  static const double _normalMin = 21;
  static const double _normalMax = 35;
  // Fixed y-axis scale for consistent bar sizing
  static const double _yAxisMin = 15;
  static const double _yAxisMax = 45;
  static const double _barWidth = 32.0;

  @override
  Widget build(BuildContext context) {
    // Empty state: no data at all
    if (cycles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: EmptyState(
          icon: Icons.history_rounded,
          iconColor: AppColors.pregnancyGold,
          title: 'No cycle history yet',
          subtitle: 'Log your first period to start seeing cycle length trends.',
        ),
      );
    }

    // Single cycle: show friendly message instead of misleading single bar
    if (cycles.length == 1) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded, size: 40, color: AppColors.mistySage.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              '${cycles.first.round()} days',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.mistySage),
            ),
            const SizedBox(height: 8),
            const Text(
              'First cycle length recorded!',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Log at least 2 more periods to start seeing your cycle length trend.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      );
    }

    // 2+ cycles: render the bar chart
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double labelSpace = 24.0;
          const double topPadding = 20.0; // room for value labels above bars
          final double chartHeight = constraints.maxHeight - labelSpace - topPadding;
          final double range = _yAxisMax - _yAxisMin;

          // Normal range band positions (as fraction of chart height)
          final double normalMinY = chartHeight - ((_normalMin - _yAxisMin) / range * chartHeight);
          final double normalMaxY = chartHeight - ((_normalMax - _yAxisMin) / range * chartHeight);

          return Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Normal range band (21-35 days)
                    Positioned(
                      top: normalMaxY,
                      left: 0,
                      right: 0,
                      height: normalMinY - normalMaxY,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.fertileGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    // Normal range labels
                    Positioned(
                      top: normalMaxY - 2,
                      right: 4,
                      child: Text('35d', style: TextStyle(fontSize: 8, color: AppColors.fertileGreen.withValues(alpha: 0.6))),
                    ),
                    Positioned(
                      top: normalMinY - 2,
                      right: 4,
                      child: Text('21d', style: TextStyle(fontSize: 8, color: AppColors.fertileGreen.withValues(alpha: 0.6))),
                    ),
                    // Bars
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: cycles.reversed.toList().asMap().entries.map((e) {
                        final double cycleLength = e.value;
                        final double barHeight = ((cycleLength - _yAxisMin) / range * chartHeight).clamp(4.0, chartHeight);
                        final bool inNormalRange = cycleLength >= _normalMin && cycleLength <= _normalMax;

                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Value label above bar
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  '${cycleLength.round()}d',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: inNormalRange ? AppColors.fertileGreen : AppColors.nudeRose,
                                  ),
                                ),
                              ),
                              // Bar
                              Container(
                                height: barHeight,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                constraints: const BoxConstraints(maxWidth: _barWidth),
                                decoration: BoxDecoration(
                                  color: inNormalRange
                                      ? AppColors.fertileGreen.withValues(alpha: 0.7)
                                      : AppColors.nudeRose,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // X-axis label
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '← Older    Cycles    Newer →',
                  style: TextStyle(fontSize: 9, color: AppColors.textSecondary.withValues(alpha: 0.6)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PatternHighlights extends StatelessWidget {
  final int cyclesTracked;
  const _PatternHighlights({required this.cyclesTracked});

  @override
  Widget build(BuildContext context) {
    final items = [
      if (cyclesTracked >= 3) _HighlightItem(icon: Icons.check_circle_outline_rounded, color: AppColors.fertileGreen, text: '$cyclesTracked cycles tracked — great consistency!'),
      _HighlightItem(icon: Icons.lightbulb_outline_rounded, color: AppColors.nudeRose, text: 'Logging daily symptoms improves PCOS pattern detection accuracy.'),
      _HighlightItem(icon: Icons.restaurant_menu_rounded, color: AppColors.mistySage, text: 'Nutrition scoring improves when you log meals at least 5 days a week.'),
    ];
    return Column(children: items.map((i) => _buildItem(i)).toList());
  }

  Widget _buildItem(_HighlightItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: item.color, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(item.text, style: const TextStyle(fontSize: 13, height: 1.4))),
        ],
      ),
    );
  }
}

class _HighlightItem {
  final IconData icon;
  final Color color;
  final String text;
  const _HighlightItem({required this.icon, required this.color, required this.text});
}

class _PregnancyProgressBar extends StatelessWidget {
  final int week;
  const _PregnancyProgressBar({required this.week});

  @override
  Widget build(BuildContext context) {
    final progress = (week / 40.0).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Week $week of 40', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${(progress * 100).round()}% complete',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.pregnancyGold.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pregnancyGold),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TrimesterLabel('1st\nTrimester', week <= 13),
              _TrimesterLabel('2nd\nTrimester', week > 13 && week <= 26),
              _TrimesterLabel('3rd\nTrimester', week > 26),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrimesterLabel extends StatelessWidget {
  final String label;
  final bool active;
  const _TrimesterLabel(this.label, this.active);

  @override
  Widget build(BuildContext context) {
    return Text(label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          color: active ? AppColors.pregnancyGold : AppColors.textSecondary,
        ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM LOCK UI
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumFeatureLock extends StatelessWidget {
  final Widget child;
  final bool isPremium;
  final String? featureName;

  const _PremiumFeatureLock({
    required this.child,
    required this.isPremium,
    this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    if (isPremium) return child;

    return Stack(
      children: [
        // The blurred child
        Opacity(
          opacity: 0.4,
          child: AbsorbPointer(child: child),
        ),
        
        // Lock Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.pregnancyGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_rounded, color: AppColors.pregnancyGold, size: 20),
                  ),
                  if (featureName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pregnancyGold.withValues(alpha: 0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HealthBrainInsightCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(healthAnalyticsProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.nudeRose, AppColors.nudeRose.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.nudeRose.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Brain Insight',
                  style: GoogleFonts.montserrat(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
                const SizedBox(height: 4),
                Text(
                  analytics.insight,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightTrendChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(healthAnalyticsProvider);
    final trend = analytics.weightTrend;

    if (trend.isEmpty || trend.every((e) => e == 0)) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: const EmptyState(
          icon: Icons.monitor_weight_outlined,
          iconColor: AppColors.nudeRose,
          title: 'No weight data yet',
          subtitle: 'Log your weight in your Daily Wellness Log to start seeing trends.',
        ),
      );
    }

    final maxWeight = trend.reduce((a, b) => a > b ? a : b);
    final minWeight = trend.where((e) => e > 0).reduce((a, b) => a < b ? a : b);
    final range = maxWeight - minWeight;

    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: trend.take(7).toList().asMap().entries.map((e) {
          final h = range == 0 ? 40.0 : ((e.value - minWeight) / range * 40 + 20);
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${e.value.round()}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Container(
                  height: h,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF64B5F6).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF64B5F6).withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WellnessRadarChart extends ConsumerWidget {
  const _WellnessRadarChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(healthAnalyticsProvider);
    final matrix = analytics.wellnessMatrix;
    final avg = matrix.values.fold(0.0, (a, b) => a + b) / matrix.length;

    String status = 'Stable';
    Color statusColor = AppColors.fertileGreen;
    if (avg > 0.8) {
      status = 'Excellent Stability';
    } else if (avg > 0.6) {
      status = 'Well Balanced';
    } else if (avg > 0.4) {
      status = 'Moderate Balance';
      statusColor = AppColors.pregnancyGold;
    } else {
      status = 'Needs Attention';
      statusColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: _SectionTitle('Wellness Analysis')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: CustomPaint(
                painter: _WellnessRadarPainter(matrix: matrix),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Based on your last 30 days of logging',
            style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _WellnessRadarPainter extends CustomPainter {
  final Map<String, double> matrix;
  _WellnessRadarPainter({required this.matrix});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    final axes = matrix.keys.toList();
    final angleStep = (2 * 3.14159) / axes.length;

    // Draw background webs
    final webPaint = Paint()
      ..color = AppColors.nudeRose.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final r = radius * (i / 4);
      final path = Path();
      for (int j = 0; j < axes.length; j++) {
        final x = center.dx + r * Math.cos(j * angleStep - 3.14159 / 2);
        final y = center.dy + r * Math.sin(j * angleStep - 3.14159 / 2);
        if (j == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, webPaint);
    }

    final points = <Offset>[];
    for (int i = 0; i < axes.length; i++) {
      final val = (matrix[axes[i]] ?? 0.5).clamp(0.1, 1.0);
      final r = radius * val;
      final x = center.dx + r * Math.cos(i * angleStep - 3.14159 / 2);
      final y = center.dy + r * Math.sin(i * angleStep - 3.14159 / 2);
      points.add(Offset(x, y));
    }

    final categoryColors = {
      'Cycle': AppColors.nudeRose,
      'Symptoms': const Color(0xFF9575CD),
      'Diet': AppColors.fertileGreen,
      'Activity': const Color(0xFF4FC3F7),
      'Stress': const Color(0xFFFFB74D),
      'Sleep': const Color(0xFF4DB6AC),
    };

    final segmentAngle = (2 * 3.14159) / axes.length;

    // Draw background layers (concentric circles)
    final gridPaint = Paint()
      ..color = AppColors.mistySage.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    
    for (int i = 4; i >= 1; i--) {
      canvas.drawCircle(center, radius * (i / 4), gridPaint);
      canvas.drawCircle(center, radius * (i / 4), Paint()
        ..color = AppColors.mistySage.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1);
    }

    // Draw individual "Layers" (Petals) for each category
    for (int i = 0; i < axes.length; i++) {
      final label = axes[i];
      final color = categoryColors[label] ?? AppColors.textSecondary;
      final val = (matrix[label] ?? 0.5).clamp(0.1, 1.0);
      final r = radius * val;
      
      final startAngle = i * segmentAngle - 3.14159 / 2 - (segmentAngle * 0.4);
      final endAngle = (i + 1) * segmentAngle - 3.14159 / 2 - (segmentAngle * 0.6);

      // Draw the Petal (Wedge)
      final petalPath = Path();
      petalPath.moveTo(center.dx, center.dy);
      petalPath.arcTo(
        Rect.fromCircle(center: center, radius: r),
        i * segmentAngle - 3.14159 / 2 - (segmentAngle / 2),
        segmentAngle * 0.9, // Small gap between petals
        false,
      );
      petalPath.close();

      // Layered effect with gradient
      canvas.drawPath(
        petalPath,
        Paint()
          ..shader = RadialGradient(
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.6)],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.fill,
      );

      // Outer border of the petal
      canvas.drawPath(
        petalPath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Label position
      final labelR = radius + 30;
      final labelX = center.dx + labelR * Math.cos(i * segmentAngle - 3.14159 / 2);
      final labelY = center.dy + labelR * Math.sin(i * segmentAngle - 3.14159 / 2);
      
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: label,
        style: GoogleFonts.montserrat(
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
