import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../domain/models/nutrition_models.dart';
import 'package:fl_chart/fl_chart.dart';

class MacroNutrientCard extends StatelessWidget {
  final NutritionSummary summary;
  final String? calorieGoalNote;

  const MacroNutrientCard({
    super.key,
    required this.summary,
    this.calorieGoalNote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Daily Goal', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                   const SizedBox(height: 4),
                   Text('${summary.totalCalories} / ${summary.targetCalories} kcal', 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.nudeRose.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${summary.remainingCalories} left',
                  style: const TextStyle(color: AppColors.nudeRose, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          if (calorieGoalNote != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.nudeRose.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: AppColors.nudeRose),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      calorieGoalNote!,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              SizedBox(
                height: 130,
                width: 130,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                         value: summary.proteinPercentage.clamp(1, 100),
                         color: AppColors.nudeRose,
                         radius: 14,
                         showTitle: false,
                      ),
                      PieChartSectionData(
                         value: summary.carbsPercentage.clamp(1, 100),
                         color: AppColors.mistySage,
                         radius: 14,
                         showTitle: false,
                      ),
                      PieChartSectionData(
                         value: summary.fatsPercentage.clamp(1, 100),
                         color: AppColors.pregnancyGold,
                         radius: 14,
                         showTitle: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    _MacroItem('Protein', summary.protein, summary.proteinPercentage, AppColors.nudeRose),
                    const SizedBox(height: 14),
                    _MacroItem('Carbs', summary.carbs, summary.carbsPercentage, AppColors.mistySage),
                    const SizedBox(height: 14),
                    _MacroItem('Fats', summary.fats, summary.fatsPercentage, AppColors.pregnancyGold),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(height: 1, color: AppColors.oldLace),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.nudeRose, size: 20),
              const SizedBox(width: 10),
              Text('Hormone Harmony Coach', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.2)),
            ],
          ),
          const SizedBox(height: 16),
          if (summary.alerts.isEmpty)
             const Text("You're tracking perfectly today! No imbalances detected.", 
               style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
          ...summary.alerts.map((alert) => _buildInsightTile(alert)),
        ],
      ),
    );
  }

  Widget _buildInsightTile(NutritionAlert alert) {
    Color color = alert.type == 'warning' ? AppColors.error : alert.type == 'success' ? AppColors.fertileGreen : AppColors.nudeRose;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Icon(alert.type == 'warning' ? Icons.report_problem_rounded : Icons.check_circle_rounded, color: color, size: 16),
               const SizedBox(width: 8),
               Text(alert.message, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Text(alert.suggestion, style: const TextStyle(fontSize: 12, height: 1.5, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final double value;
  final double percentage;
  final Color color;

  const _MacroItem(this.label, this.value, this.percentage, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${value.toInt()}g', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text('${percentage.toInt()}%', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
