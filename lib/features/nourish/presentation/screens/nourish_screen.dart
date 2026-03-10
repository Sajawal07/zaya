import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_colors.dart';
import 'scan_plate_screen.dart';
import '../../domain/models/recipe.dart';
import '../widgets/macro_nutrient_card.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import '../../../../providers/pcos_provider.dart';
import '../../../health/domain/models/pcos_guidance.dart';
import '../widgets/add_food_sheet.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../../../providers/nutrition_provider.dart';
import 'package:zaya/models/nutrition_enums.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: nutrition.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
            slivers: [
              _buildAppBar(context),
              _buildMacroSection(nutrition),
              _buildActionButtons(context),
              
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Text(
                    'PCOS-Specific Guidance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              _buildGuidanceCard(pcos?.analysis != null 
                ? PcosGuidance.getGuidance(pcos!.analysis!.pattern).dietGoal 
                : 'Maintain a balanced diet with low GI foods.'),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Text(
                    'Logged Today',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              if (nutrition.todayLogs.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text('No meals logged yet today.', style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final log = nutrition.todayLogs[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.fertileGreen.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.fertileGreen),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(log.itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${log.calories} kcal • ${log.type.name}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: nutrition.todayLogs.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Text(
                    'Planned Meals',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              if (nutrition.breakfast != null && !nutrition.currentPlan!.loggedMealTypes.contains(MealType.breakfast.name))
                _buildMealSection('Breakfast', nutrition.breakfast!, nutrition.currentPlan?.breakfastPortion ?? 1.0, MealType.breakfast, nutrition),
              
              if (nutrition.lunch != null && !nutrition.currentPlan!.loggedMealTypes.contains(MealType.lunch.name))
                _buildMealSection('Lunch', nutrition.lunch!, nutrition.currentPlan?.lunchPortion ?? 1.0, MealType.lunch, nutrition),
              
              if (nutrition.dinner != null && !nutrition.currentPlan!.loggedMealTypes.contains(MealType.dinner.name))
                _buildMealSection('Dinner', nutrition.dinner!, nutrition.currentPlan?.dinnerPortion ?? 1.0, MealType.dinner, nutrition),
              
              // Only show snacks if not logged (logic simplified for brevity, usually snacks can be multiple)
              if (nutrition.snacks.isNotEmpty)
                ...nutrition.snacks.where((s) => !nutrition.currentPlan!.loggedMealTypes.contains('${s.id}_snack')).map((s) {
                   return _buildMealSection('Snack', s, 1.0, MealType.snack, nutrition);
                }),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nourish', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Text('Fuel your body, balance your hormones', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.nudeRose),
                onPressed: () => ref.read(nutritionProvider.notifier).regeneratePlan(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSection(NutritionState state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: MacroNutrientCard(
          caloriesConsumed: state.totalCalories,
          calorieTarget: 2000, // TODO: Get from user target settings
          protein: state.totalProtein,
          carbs: state.totalCarbs,
          fats: state.totalFats,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.add_rounded,
                label: 'Log Food',
                onTap: () => _showAddFoodSheet(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ActionButton(
                icon: Icons.camera_alt_rounded,
                label: 'Scan Plate',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const ScanPlateScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealSection(String label, Recipe recipe, double portion, MealType type, NutritionState state) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      sliver: SliverToBoxAdapter(
        child: _buildMealCard(label, recipe, portion, type, state),
      ),
    );
  }

  Widget _buildMealCard(String label, Recipe recipe, double portion, MealType type, NutritionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => ref.read(nutritionProvider.notifier).confirmMeal(type, recipe, portion),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('Log Meal'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.fertileGreen),
                ),
                TextButton(
                  onPressed: () => _showSwapOptions(type),
                  child: const Text('Swap', style: TextStyle(color: AppColors.nudeRose)),
                ),
              ],
            ),
          ],
        ),
        RecipeCard(
          recipe: recipe,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => RecipeDetailScreen(recipe: recipe, portion: portion)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.mistySage.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text('Adjust Portion', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                   Text('${portion}x', style: const TextStyle(fontSize: 13, color: AppColors.nudeRose, fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: portion,
                min: 0.5,
                max: 2.0,
                divisions: 6,
                activeColor: AppColors.nudeRose,
                inactiveColor: AppColors.oldLace,
                onChanged: (v) {
                  ref.read(nutritionProvider.notifier).adjustPortion(type, v);
                },
              ),
              const Center(
                child: Text(
                  'Daily calories updated based on portion.',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

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
    final options = RecipeRepository.getRecipesByPattern(pattern).where((r) => r.mealType == type).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Swap $type', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.nudeRose),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
