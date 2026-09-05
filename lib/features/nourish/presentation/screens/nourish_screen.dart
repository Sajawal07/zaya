import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';

import '../../domain/models/recipe.dart';
import '../widgets/macro_nutrient_card.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import '../../../../providers/pcos_provider.dart';
import '../../../health/domain/models/pcos_guidance.dart';
import '../widgets/add_food_sheet.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../../../providers/nutrition_provider.dart';
import 'package:hercycle_bloom/models/nutrition_enums.dart';
import '../../domain/models/nutrition_models.dart';
import '../../domain/services/meal_scoring_engine.dart';
import 'package:hercycle_bloom/models/nutrition_log.dart';
import '../widgets/meal_radar_chart.dart';
import 'package:hercycle_bloom/providers/premium_provider.dart';
import 'package:hercycle_bloom/features/health/presentation/screens/health_hub_screen.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';

class NourishScreen extends ConsumerStatefulWidget {
  const NourishScreen({super.key});

  @override
  ConsumerState<NourishScreen> createState() => _NourishScreenState();
}

class _NourishScreenState extends ConsumerState<NourishScreen> {
  @override
  Widget build(BuildContext context) {
    final nutrition = ref.watch(nutritionProvider);
    final pcos = ref.watch(pcosProvider).value;
    final isPremium = ref.watch(isPremiumProvider);
    final calorieGoalNote = pcos?.metrics.calorieGoalNote;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: nutrition.isLoading
            ? const AppLoaderCentered()
            : CustomScrollView(
                slivers: [
                  _buildAppBar(context),
                  _buildMacroSection(nutrition, calorieGoalNote),
                  _buildDailyScoreCard(nutrition),

                  // ── Hormone-Support Score Trend (Premium only) ────────
                  if (isPremium) ...[
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                        child: Text(
                          'Hormone-Support Nutrition Score',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildWeeklyTrendSection()),
                  ],

                  _buildActionButtons(context),

                  // ── AI Coach Recommendations (Premium only) ───────────
                  if (isPremium &&
                      (nutrition.summary?.recommendations.isNotEmpty ?? false)) ...[
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                        child: Text(
                          'Coach Recommendations',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildRecommendationsSection(
                        nutrition.summary!.recommendations,
                      ),
                    ),
                  ],

                  // ── PCOS Guidance ───────────────────────────────────────
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Text(
                        'PCOS-Specific Guidance',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  _buildGuidanceCard(
                    pcos?.analysis != null
                        ? PcosGuidance.getGuidance(pcos!.analysis!.pattern).dietGoal
                        : 'Maintain a balanced diet with low GI foods.',
                  ),

                  // ── Logged Meals ────────────────────────────────────────
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Text(
                        'Logged Today',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  _buildLoggedMealsSection(nutrition),

                  // ── Planned Meals ───────────────────────────────────────
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Text(
                        'Planned Meals',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  if (nutrition.breakfast != null &&
                      !(nutrition.currentPlan?.loggedMealTypes.contains(MealType.breakfast.name) ?? false))
                    _buildMealSection('Breakfast', nutrition.breakfast!,
                        nutrition.currentPlan?.breakfastPortion ?? 1.0, MealType.breakfast, nutrition),

                  if (nutrition.lunch != null &&
                      !(nutrition.currentPlan?.loggedMealTypes.contains(MealType.lunch.name) ?? false))
                    _buildMealSection('Lunch', nutrition.lunch!,
                        nutrition.currentPlan?.lunchPortion ?? 1.0, MealType.lunch, nutrition),

                  if (nutrition.dinner != null &&
                      !(nutrition.currentPlan?.loggedMealTypes.contains(MealType.dinner.name) ?? false))
                    _buildMealSection('Dinner', nutrition.dinner!,
                        nutrition.currentPlan?.dinnerPortion ?? 1.0, MealType.dinner, nutrition),

                  if (nutrition.snacks.isNotEmpty)
                    ...nutrition.snacks
                        .where((s) =>
                            !(nutrition.currentPlan?.loggedMealTypes.contains('${s.id}_snack') ?? false))
                        .map((s) => _buildMealSection('Snack', s, 1.0, MealType.snack, nutrition)),

                  // Clear the floating AI FAB so bottom content is not obscured
                  const SliverToBoxAdapter(child: SizedBox(height: 170)),
                ],
              ),
      ),
    );
  }

  // ── App Bar ─────────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nourish',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Text('Fuel your body, balance your hormones',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.health_and_safety_outlined, color: AppColors.nudeRose),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthHubScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.nudeRose),
                    onPressed: () => ref.read(nutritionProvider.notifier).regeneratePlan(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Daily Nutrition Score Card ─────────────────────────────────────────────

  Widget _buildDailyScoreCard(NutritionState state) {
    final summary = state.summary;
    final score = summary?.dailyScore ?? 0.0;
    final hasScore = score > 0;

    final Color scoreColor = score >= 8.5
        ? AppColors.fertileGreen
        : score >= 6.5
            ? AppColors.nudeRose
            : const Color(0xFFE07B54);

    final String scoreLabel = score >= 8.5
        ? 'Excellent — Hormone Harmony 🌿'
        : score >= 6.5
            ? 'Good — Keep going 💪'
            : score > 0
                ? 'Room to improve — check coach tips'
                : 'Log a meal to see your score';

    // Calculate real 7-day average from weekly scores
    final weekScores = state.weeklyScores.whereType<double>().toList();
    final weekAvg = weekScores.isNotEmpty
        ? (weekScores.reduce((a, b) => a + b) / weekScores.length).clamp(0.0, 10.0)
        : 0.0;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: scoreColor.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Row(
            children: [
              // Score ring — animated pulsing ring when empty, static when scored
              SizedBox(
                width: 72,
                height: 72,
                child: hasScore
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: score / 10.0,
                            strokeWidth: 6,
                            backgroundColor: scoreColor.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                          ),
                          Center(
                            child: Text(
                              score.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: scoreColor,
                              ),
                            ),
                          ),
                        ],
                      )
                    : _buildEmptyScoreRing(scoreColor),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Nutrition Score',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scoreLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _scorePill('Goal', '8.5+', AppColors.fertileGreen.withValues(alpha: 0.1), AppColors.fertileGreen),
                        const SizedBox(width: 8),
                        if (weekAvg > 0)
                          _scorePill('7-day avg', weekAvg.toStringAsFixed(1), AppColors.nudeRose.withValues(alpha: 0.1), AppColors.nudeRose),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scorePill(String label, String value, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(fontSize: 10, color: fg.withValues(alpha: 0.8)),
            ),
            TextSpan(
              text: value,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
            ),
          ],
        ),
      ),
    );
  }

  // Animated ring shown in the empty-state branch of the score card.
  // Pulses a thin arc segment so the ring feels alive even before any
  // meals have been logged, and draws a subtle CTA arrow beneath it.
  Widget _buildEmptyScoreRing(Color scoreColor) {
    return _NutritionScoreRing(scoreColor: scoreColor);
  }

  // ── Macro Card ───────────────────────────────────────────────────────────────

  Widget _buildMacroSection(NutritionState state, String? calorieGoalNote) {
    if (state.summary == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(child: MacroNutrientCard(summary: state.summary!, calorieGoalNote: calorieGoalNote)),
    );
  }

  // ── Action Buttons ───────────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      sliver: SliverToBoxAdapter(
        child: _ActionButton(
          icon: Icons.add_rounded,
          label: 'Log Food',
          onTap: () => _showAddFoodSheet(context),
        ),
      ),
    );
  }

  // ── Guidance Card ────────────────────────────────────────────────────────────

  Widget _buildGuidanceCard(String text) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.nudeRose, Color(0xFFE8998D)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(text,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logged Meals ─────────────────────────────────────────────────────────────

  Widget _buildLoggedMealsSection(NutritionState nutrition) {
    if (nutrition.todayLogs.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: EmptyState(
            icon: Icons.restaurant_menu_rounded,
            title: 'No meals logged today',
            subtitle: "Tap 'Log Food' below to add your first meal and see your hormone harmony score!",
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final log = nutrition.todayLogs[index];
            final score = log.pcosScore ?? 7.5;

            return GestureDetector(
              onTap: () => _showMealImpactSheet(context, log),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.mistySage.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (score > 8
                                ? AppColors.fertileGreen
                                : score > 6
                                    ? AppColors.nudeRose
                                    : AppColors.error)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          score.toStringAsFixed(1),
                          style: TextStyle(
                            color: score > 8
                                ? AppColors.fertileGreen
                                : score > 6
                                    ? AppColors.nudeRose
                                    : AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.itemName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(
                            '${log.calories} kcal • P: ${log.protein.toInt()}g  C: ${log.carbs.toInt()}g',
                            style:
                                const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ),
            );
          },
          childCount: nutrition.todayLogs.length,
        ),
      ),
    );
  }

  // ── Meal Impact Sheet ─────────────────────────────────────────────────────────

  void _showMealImpactSheet(BuildContext context, NutritionLog log) {
    final isPremium = ref.read(isPremiumProvider);
    final score = MealScoringEngine.calculateMealScore(
      name: log.itemName,
      calories: log.calories.toDouble(),
      protein: log.protein,
      carbs: log.carbs,
      fats: log.fats,
      fiber: log.fiber,
      glycemicIndex: log.glycemicIndex,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.oldLace,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildCircularScore(score.totalScore),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.itemName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(
                          'Hormone Impact Analysis',
                          style: TextStyle(
                              color: AppColors.nudeRose.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Radar Chart (Premium only — free users don't see locked UI)
              if (isPremium) ...[
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.oldLace.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: MealRadarChart(score: score, size: 180),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              const Text('Evidence-Based Breakdown',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 16),
              _buildMetricRow('Insulin Impact', score.insulinImpact / 10,
                  'Lower is better for PCOS'),
              const SizedBox(height: 12),
              _buildMetricRow('Inflammation', score.inflammationScore / 10,
                  'Avoiding inflammatory triggers'),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              ...score.factors.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          f.isPositive
                              ? Icons.check_circle_rounded
                              : Icons.info_rounded,
                          color: f.isPositive
                              ? AppColors.fertileGreen
                              : AppColors.nudeRose,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.label,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(f.detail,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16)),
                child: Text(score.pcosInsight,
                    style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        height: 1.4)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularScore(double score) {
    final color = score > 8
        ? AppColors.fertileGreen
        : score > 6
            ? AppColors.nudeRose
            : AppColors.error;
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
      child: Center(
        child: Text(score.toStringAsFixed(1),
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  Widget _buildMetricRow(String label, double value, String helper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('${(value * 100).toInt()}%',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        Text(helper,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: AppColors.oldLace,
            color: value > 0.7 ? AppColors.error : AppColors.nudeRose,
          ),
        ),
      ],
    );
  }

  // ── Weekly Trend ─────────────────────────────────────────────────────────────

  Widget _buildWeeklyTrendSection() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final nutrition = ref.watch(nutritionProvider);
    final scores = nutrition.weeklyScores;
    
    // Calculate this week's average (only days with data)
    final thisWeekScores = scores.whereType<double>().toList();
    final thisWeekAvg = thisWeekScores.isNotEmpty
        ? thisWeekScores.reduce((a, b) => a + b) / thisWeekScores.length
        : 0.0;

    // Calculate trend (compare avg to a baseline of 7.0 if no last week data)
    final trendPercent = thisWeekAvg > 0 ? ((thisWeekAvg - 7.0) / 7.0 * 100).round() : 0;
    final trendUp = trendPercent >= 0;

    return Container(
      height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(days.length, (index) {
                final score = index < scores.length ? scores[index] : null;
                final barHeight = score != null ? (score / 10) * 60 : 0.0;
                return Column(
                  children: [
                    Container(
                      width: 12,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.oldLace,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          if (score != null)
                            Container(
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: score > 8
                                    ? AppColors.fertileGreen
                                    : score > 6
                                        ? AppColors.nudeRose
                                        : AppColors.error,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(days[index],
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary)),
                  ],
                );
              }),
            ),
            const Spacer(),
            if (thisWeekAvg > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    size: 14,
                    color: trendUp ? AppColors.fertileGreen : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    trendUp
                        ? 'Nutrition score up $trendPercent% this week'
                        : 'Nutrition score down ${trendPercent.abs()}% this week',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: (trendUp ? AppColors.fertileGreen : AppColors.error).withValues(alpha: 0.8)),
                  ),
                ],
              )
            else
              const Text(
                'Log meals to see your weekly trend',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
          ],
        ),
    );
  }

  // ── AI Recommendations ────────────────────────────────────────────────────────

  Widget _buildRecommendationsSection(List<MealRecommendation> recs) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: recs.length,
          itemBuilder: (context, index) {
            final rec = recs[index];
            return Container(
              width: 280,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: AppColors.nudeRose, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(rec.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(rec.why,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const Spacer(),
                  Wrap(
                    spacing: 8,
                    children: rec.benefits
                        .take(2)
                        .map((b) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color:
                                      AppColors.fertileGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(b,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.fertileGreen,
                                      fontWeight: FontWeight.bold)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            );
          },
        ),
      );
  }

  // ── Planned Meal Section ──────────────────────────────────────────────────────

  Widget _buildMealSection(String label, Recipe recipe, double portion,
      MealType type, NutritionState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => ref
                          .read(nutritionProvider.notifier)
                          .confirmMeal(type, recipe, portion),
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 18),
                      label: const Text('Log Meal'),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.fertileGreen),
                    ),
                    TextButton(
                      onPressed: () => _showSwapOptions(type),
                      child: const Text('Swap',
                          style: TextStyle(color: AppColors.nudeRose)),
                    ),
                  ],
                ),
              ],
            ),
            RecipeCard(
              recipe: recipe,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) =>
                        RecipeDetailScreen(recipe: recipe, portion: portion)),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.mistySage.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Adjust Portion',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('${portion}x',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.nudeRose,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: portion,
                    min: 0.5,
                    max: 2.0,
                    divisions: 6,
                    activeColor: AppColors.nudeRose,
                    inactiveColor: AppColors.oldLace,
                    onChanged: (v) =>
                        ref.read(nutritionProvider.notifier).adjustPortion(type, v),
                  ),
                  const Center(
                    child: Text(
                      'Daily calories updated based on portion.',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Modals ────────────────────────────────────────────────────────────────────

  void _showAddFoodSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddFoodSheet(),
    );
  }

  void _showSwapOptions(MealType type) {
    final pcosState = ref.read(pcosProvider).value;
    final pattern = pcosState?.analysis?.pattern ?? PcosPattern.none;
    final options = RecipeRepository.getRecipesByPattern(pattern)
        .where((r) => r.mealType == type)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Swap $type',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final r = options[index];
                return ListTile(
                  title: Text(r.title),
                  subtitle: Text('${r.calories} kcal'),
                  onTap: () {
                    ref.read(nutritionProvider.notifier).swapDish(type, r.id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Support Widgets ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.nudeRose),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ── Animated empty-state score ring ─────────────────────────────────────────
// Pulses a small arc segment around a thin background circle so the ring
// feels alive even before any meals have been logged. The dash '—' sits
// in the center. A tiny CTA arrow is drawn below the ring to hint that
// tapping the log button is the next step.
class _NutritionScoreRing extends StatefulWidget {
  final Color scoreColor;
  const _NutritionScoreRing({required this.scoreColor});

  @override
  State<_NutritionScoreRing> createState() => _NutritionScoreRingState();
}

class _NutritionScoreRingState extends State<_NutritionScoreRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) {
        // Sine-ish pulse: 0.0 → 0.10 → 0.0 over each cycle
        final t = (_pulseCtrl.value * 2 - 1).abs(); // 0→1→0
        final arcSweep = 0.02 + t * 0.10; // 0.02 → 0.12 → 0.02

        return CustomPaint(
          painter: _EmptyRingPainter(
            arcSweep: arcSweep,
            bgColor: widget.scoreColor.withValues(alpha: 0.12),
            arcColor: widget.scoreColor,
          ),
          child: const Center(
            child: Text(
              '—',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyRingPainter extends CustomPainter {
  final double arcSweep;
  final Color bgColor;
  final Color arcColor;

  _EmptyRingPainter({
    required this.arcSweep,
    required this.bgColor,
    required this.arcColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2; // match strokeWidth: 6
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = bgColor;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = arcColor;

    // Faint background circle
    canvas.drawCircle(center, radius, bgPaint);
    // Animated arc segment starting from top (−π/2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      arcSweep * 2 * math.pi,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_EmptyRingPainter old) => old.arcSweep != arcSweep;
}
