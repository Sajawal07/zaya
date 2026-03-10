
import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class MacroNutrientCard extends StatelessWidget {
  final int caloriesConsumed;
  final int calorieTarget;
  final double protein;
  final double carbs;
  final double fats;

  const MacroNutrientCard({
    super.key,
    required this.caloriesConsumed,
    required this.calorieTarget,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCalorieExceeded = caloriesConsumed > calorieTarget;
    
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calories',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$caloriesConsumed',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: isCalorieExceeded ? AppColors.error : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' / $calorieTarget kcal',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Simple Ring Chart for Calories
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: (caloriesConsumed / calorieTarget).clamp(0.0, 1.0),
                        backgroundColor: AppColors.mistySage.withOpacity(0.2),
                        color: isCalorieExceeded ? AppColors.error : AppColors.mistySage,
                        strokeWidth: 8,
                      ),
                      Icon(
                        isCalorieExceeded ? Icons.warning_amber_rounded : Icons.local_fire_department_rounded,
                        color: isCalorieExceeded ? AppColors.error : AppColors.mistySage,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Macro bars
            _buildMacroBar(context, 'Protein', protein, 100, AppColors.nudeRose), // 100g target example
            const SizedBox(height: 12),
            _buildMacroBar(context, 'Carbs', carbs, 150, AppColors.mistySage), // 150g target example
            const SizedBox(height: 12),
            _buildMacroBar(context, 'Fats', fats, 60, AppColors.pregnancyGold), // 60g target example
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBar(BuildContext context, String label, double value, double target, Color baseColor) {
    final bool isExceeded = value > target;
    final double overflow = value - target;
    final Color barColor = isExceeded ? AppColors.error : baseColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isExceeded)
                  Text(
                    '${overflow.toInt()}g over target',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${value.toInt()} / ${target.toInt()}g',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (isExceeded)
                   const Text(
                    'Over recommended intake',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.error,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.mistySage.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: (value / target).clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    if (!isExceeded)
                      BoxShadow(
                        color: barColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
