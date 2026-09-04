import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_colors.dart';
import '../../../../providers/metrics_provider.dart';

class BabyScreen extends ConsumerWidget {
  const BabyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(userMetricsProvider).value;
    final startDate = metrics?.lastPeriodDate;
    final now = DateTime.now();
    final week = startDate != null ? (now.difference(startDate).inDays ~/ 7).clamp(1, 40) : 1;

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
                    Text('Baby',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Text("Your little one's journey",
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),

            // ── Current Week Card ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverToBoxAdapter(child: _WeekHeroCard(week: week)),
            ),

            // ── Size Comparison ────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Text('Size This Week',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              sliver: SliverToBoxAdapter(child: _SizeComparisonCard(week: week)),
            ),

            // ── Development Milestones ─────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: const Text('Development This Week',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              sliver: SliverToBoxAdapter(child: _DevelopmentCard(week: week)),
            ),

            // ── Milestone Timeline ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: const Text('Upcoming Milestones',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              sliver: SliverToBoxAdapter(child: _MilestoneTimeline(currentWeek: week)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _WeekHeroCard extends StatelessWidget {
  final int week;
  const _WeekHeroCard({required this.week});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A9373), Color(0xFF6DB99A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4A9373).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Week', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text('$week', style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold, height: 1)),
              const Text('of 40', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.pregnant_woman_rounded, color: Colors.white, size: 60),
              const SizedBox(height: 8),
              Text(_trimesterLabel(week),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  String _trimesterLabel(int w) {
    if (w <= 13) return '1st Trimester';
    if (w <= 26) return '2nd Trimester';
    return '3rd Trimester';
  }
}

class _SizeComparisonCard extends StatelessWidget {
  final int week;
  const _SizeComparisonCard({required this.week});

  static const _sizes = {
    4: ('Poppy Seed', '🌱', '1 mm'),
    6: ('Sweet Pea', '🫛', '6 mm'),
    8: ('Raspberry', '🫐', '16 mm'),
    10: ('Strawberry', '🍓', '3 cm'),
    12: ('Lime', '🍋', '5.4 cm'),
    14: ('Lemon', '🍋', '8.7 cm'),
    16: ('Avocado', '🥑', '11.6 cm'),
    18: ('Bell Pepper', '🫑', '14.2 cm'),
    20: ('Banana', '🍌', '25.6 cm'),
    22: ('Papaya', '🍈', '27.8 cm'),
    24: ('Corn', '🌽', '30 cm'),
    26: ('Lettuce', '🥬', '35.6 cm'),
    28: ('Eggplant', '🍆', '37.6 cm'),
    30: ('Cabbage', '🥦', '39.9 cm'),
    32: ('Squash', '🎃', '42.4 cm'),
    34: ('Cantaloupe', '🍈', '45 cm'),
    36: ('Papaya', '🍈', '47.4 cm'),
    38: ('Watermelon', '🍉', '49.8 cm'),
    40: ('Pumpkin', '🎃', '51 cm'),
  };

  @override
  Widget build(BuildContext context) {
    final entry = _closestEntry(week);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Text(entry.$2, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.$1,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Approx. ${entry.$3}',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  (String, String, String) _closestEntry(int week) {
    final keys = _sizes.keys.toList()..sort();
    int best = keys.first;
    for (final k in keys) {
      if (k <= week) best = k;
    }
    return _sizes[best]!;
  }
}

class _DevelopmentCard extends StatelessWidget {
  final int week;
  const _DevelopmentCard({required this.week});

  static const _dev = <int, List<String>>{
    8: ['Facial features forming', 'Fingers and toes developing', 'Heart beating ~150 bpm'],
    12: ['Reflexes developing', 'Kidneys producing urine', 'Vocal cords forming'],
    16: ['Baby can make facial expressions', 'Skeleton hardening', 'Can feel gentle kicks soon'],
    20: ['Can hear sounds outside womb', 'Fingerprints fully formed', 'Eyebrows and lashes visible'],
    24: ['Lungs developing rapidly', 'Brain growing quickly', 'Face looks like a newborn\'s'],
    28: ['Eyes can open and close', 'Brain activity detectable', 'Can dream during sleep'],
    32: ['Storing fat under skin', 'Immune system strengthening', 'Practising breathing movements'],
    36: ['Most organs fully developed', 'Head likely facing down', 'Gaining ~30g per day'],
    40: ['Full term! Ready to meet you', 'All systems go', 'Typical weight: 3–3.5 kg'],
  };

  @override
  Widget build(BuildContext context) {
    final facts = _closestFacts(week);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        children: facts.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: AppColors.pregnancyGold),
              const SizedBox(width: 12),
              Expanded(child: Text(f, style: const TextStyle(fontSize: 13, height: 1.4))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  List<String> _closestFacts(int week) {
    final keys = _dev.keys.toList()..sort();
    int best = keys.first;
    for (final k in keys) {
      if (k <= week) best = k;
    }
    return _dev[best]!;
  }
}

class _MilestoneTimeline extends StatelessWidget {
  final int currentWeek;
  const _MilestoneTimeline({required this.currentWeek});

  static const _milestones = [
    (8, 'First heartbeat visible on ultrasound'),
    (12, 'End of 1st trimester — risk drops significantly'),
    (16, 'Anatomy scan window opens'),
    (20, 'Halfway there! Mid-pregnancy scan'),
    (24, 'Viability milestone'),
    (28, 'Start of 3rd trimester'),
    (32, 'GBS test & birth plan discussion'),
    (36, 'Weekly check-ups begin'),
    (40, 'Due date 🎉'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _milestones.map((m) {
        final past = m.$1 < currentWeek;
        final current = (currentWeek - m.$1).abs() <= 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: past
                        ? const Color(0xFF4A9373)
                        : current
                            ? AppColors.pregnancyGold
                            : AppColors.oldLace,
                    border: Border.all(
                      color: current ? AppColors.pregnancyGold : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    past ? Icons.check_rounded : Icons.circle,
                    size: 12,
                    color: past ? Colors.white : current ? AppColors.pregnancyGold : AppColors.textSecondary,
                  ),
                ),
                if (m != _milestones.last)
                  Container(width: 2, height: 36, color: AppColors.oldLace),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Week ${m.$1}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: past ? const Color(0xFF4A9373) : AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(m.$2,
                        style: TextStyle(
                            fontSize: 13,
                            color: current ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: current ? FontWeight.w600 : FontWeight.normal)),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
