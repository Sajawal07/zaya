import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_colors.dart';
import '../../../../providers/nutrition_provider.dart';
import '../../domain/models/food_item.dart';
import '../../data/repositories/food_repository.dart';
import '../../domain/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

enum AddFoodMode { options, search, custom, saved }

class AddFoodSheet extends ConsumerStatefulWidget {
  const AddFoodSheet({super.key});

  @override
  ConsumerState<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends ConsumerState<AddFoodSheet> {
  AddFoodMode _mode = AddFoodMode.options;
  final _formKey = GlobalKey<FormState>();
  
  // Search fields
  final _searchController = TextEditingController();
  String _searchQuery = '';
  FoodItem? _selectedFood;
  double _servingSize = 1.0;
  final List<double> _servingOptions = [0.5, 1.0, 1.5, 2.0, 3.0];
  String _selectedServingLabel = '1 serving';

  // Custom Form fields
  String _customName = '';
  int _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fats = 0;
  double _fiber = 0;
  double _gi = 50.0;

  // Saved Food fields
  Recipe? _selectedRecipe;
  double _quantity = 1.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FoodItem> get _filteredFoods {
    if (_searchQuery.isEmpty) return FoodRepository.getAll();
    final q = _searchQuery.toLowerCase();
    return FoodRepository.getAll().where((f) =>
        f.name.toLowerCase().contains(q) ||
        f.category.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              child: _buildBody(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title = 'Log Food';
    if (_mode == AddFoodMode.search) title = 'Search Foods';
    if (_mode == AddFoodMode.custom) title = 'Custom Entry';
    if (_mode == AddFoodMode.saved) title = 'Saved Foods';

    return Row(
      children: [
        if (_mode != AddFoodMode.options)
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => setState(() {
              _mode = AddFoodMode.options;
              _selectedFood = null;
              _selectedRecipe = null;
              _searchQuery = '';
              _searchController.clear();
            }),
          ),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_mode) {
      case AddFoodMode.options:
        return _buildOptions();
      case AddFoodMode.search:
        return _selectedFood == null ? _buildFoodSearch() : _buildFoodServingSelector();
      case AddFoodMode.custom:
        return _buildCustomForm();
      case AddFoodMode.saved:
        return _buildSavedFoodList();
    }
  }

  Widget _buildOptions() {
    return Column(
      children: [
        _OptionTile(
          icon: Icons.search_rounded,
          title: 'Search Food',
          subtitle: 'Find foods with auto-filled nutrition info',
          onTap: () => setState(() => _mode = AddFoodMode.search),
        ),
        const SizedBox(height: 12),
        _OptionTile(
          icon: Icons.restaurant_rounded,
          title: 'Add Custom Meal',
          subtitle: 'Enter nutrition values manually',
          onTap: () => setState(() => _mode = AddFoodMode.custom),
        ),
        const SizedBox(height: 12),
        _OptionTile(
          icon: Icons.history_rounded,
          title: 'Select From Saved Foods',
          subtitle: 'Browse our PCOS-tailored recipes',
          onTap: () => setState(() => _mode = AddFoodMode.saved),
        ),
      ],
    );
  }

  // ── Food Search ──────────────────────────────────────────────────────────

  Widget _buildFoodSearch() {
    final foods = _filteredFoods;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search foods (e.g. paratha, egg, dal...)',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 8),
        if (_searchQuery.isNotEmpty && foods.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('No foods found for "$_searchQuery"',
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _mode = AddFoodMode.custom),
                    child: const Text('Add as custom entry'),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return _FoodTile(
                food: food,
                onTap: () => setState(() => _selectedFood = food),
              );
            },
          ),
      ],
    );
  }

  // ── Food Serving Selector ────────────────────────────────────────────────

  Widget _buildFoodServingSelector() {
    final food = _selectedFood!;
    final scaledCalories = (food.calories * _servingSize).toInt();
    final scaledProtein = food.protein * _servingSize;
    final scaledCarbs = food.carbs * _servingSize;
    final scaledFats = food.fats * _servingSize;
    final scaledFiber = food.fiber * _servingSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Food info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.oldLace,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.nudeRose.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant_rounded, color: AppColors.nudeRose, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        if (food.isHormoneFriendly)
                          const Text('PCOS Friendly', style: TextStyle(fontSize: 11, color: AppColors.fertileGreen, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Nutrition preview per 1 serving
              Text('Per 1 serving:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NutrientPill('${food.calories}', 'kcal', AppColors.nudeRose),
                  _NutrientPill('${food.protein.toStringAsFixed(1)}g', 'P', AppColors.fertileGreen),
                  _NutrientPill('${food.carbs.toStringAsFixed(1)}g', 'C', AppColors.mistySage),
                  _NutrientPill('${food.fats.toStringAsFixed(1)}g', 'F', AppColors.pregnancyGold),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Serving size selector
        const Text('Serving Size', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        Row(
          children: _servingOptions.map((size) {
            final isSelected = _servingSize == size;
            final label = size == 0.5 ? '0.5x' : size == 1.0 ? '1x' : '${size.toStringAsFixed(1)}x';
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _servingSize = size;
                  _selectedServingLabel = '$label serving${size != 1.0 ? 's' : ''}';
                }),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.nudeRose : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.nudeRose : AppColors.mistySage.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Scaled nutrition preview
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.fertileGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total for $_selectedServingLabel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('$scaledCalories kcal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.fertileGreen)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NutrientPill('${scaledProtein.toStringAsFixed(1)}g', 'Protein', AppColors.nudeRose),
                  _NutrientPill('${scaledCarbs.toStringAsFixed(1)}g', 'Carbs', AppColors.mistySage),
                  _NutrientPill('${scaledFats.toStringAsFixed(1)}g', 'Fats', AppColors.pregnancyGold),
                  _NutrientPill('${scaledFiber.toStringAsFixed(1)}g', 'Fiber', AppColors.fertileGreen),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Add button
        ElevatedButton(
          onPressed: () {
            ref.read(nutritionProvider.notifier).addCustomEntry(
              food.name,
              scaledCalories,
              scaledProtein,
              scaledCarbs,
              scaledFats,
              fiber: scaledFiber,
              gi: food.glycemicIndex,
              processingLevel: food.processingLevel,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: AppColors.nudeRose,
            foregroundColor: AppColors.white,
          ),
          child: const Text('Add to Log', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ── Custom Form ──────────────────────────────────────────────────────────

  Widget _buildCustomForm() {
    final double totalMacros = _protein + _carbs + _fats;
    final bool isValid = _customName.isNotEmpty && _calories > 0;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Item Name',
              hintText: 'e.g. Walnuts, Chicken Breast',
            ),
            onChanged: (v) => setState(() => _customName = v.trim()),
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    suffixText: 'kcal',
                    helperText: 'per serving',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => _calories = int.tryParse(v) ?? 0),
                  validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter calories' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Macronutrients (Optional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMacroField('Protein', 'P (g)', (v) => _protein = v),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroField('Carbs', 'C (g)', (v) => _carbs = v),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroField('Fats', 'F (g)', (v) => _fats = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMacroField('Fiber', 'Fiber (g)', (v) => _fiber = v),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroField('GI', 'GI (0-100)', (v) => _gi = v),
              ),
            ],
          ),
          
          if (totalMacros > 0) ...[
            const SizedBox(height: 24),
            _buildMacroDistribution(totalMacros),
          ],

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: !isValid ? null : () {
              if (_formKey.currentState!.validate()) {
                ref.read(nutritionProvider.notifier).addCustomEntry(
                  _customName, _calories, _protein, _carbs, _fats,
                  fiber: _fiber, gi: _gi,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: isValid ? AppColors.nudeRose : AppColors.mistySage.withValues(alpha: 0.3),
              foregroundColor: AppColors.white,
              elevation: isValid ? 2 : 0,
            ),
            child: const Text('Save Entry', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroField(String label, String hint, Function(double) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: hint,
        helperText: 'per serving',
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) => setState(() => onChanged(double.tryParse(v) ?? 0.0)),
    );
  }

  Widget _buildMacroDistribution(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.oldLace.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Macro Balance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text('${total.toStringAsFixed(1)}g total', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _distributionPart('P', _protein / total, AppColors.nudeRose),
              _distributionPart('C', _carbs / total, AppColors.mistySage),
              _distributionPart('F', _fats / total, AppColors.pregnancyGold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _distributionPart(String label, double ratio, Color color) {
    if (ratio <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: (ratio * 100).toInt(),
      child: Container(
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ── Saved Food List ──────────────────────────────────────────────────────

  Widget _buildSavedFoodList() {
    final recipes = RecipeRepository.getAllRecipes().where((r) => 
      r.title.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search PCOS recipes...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
        const SizedBox(height: 16),
        if (_selectedRecipe == null)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final r = recipes[index];
              return ListTile(
                title: Text(r.title),
                subtitle: Text('${r.calories} kcal • ${r.mealType.name}'),
                onTap: () => setState(() => _selectedRecipe = r),
              );
            },
          )
        else
          _buildRecipeQuantitySelector(),
      ],
    );
  }

  Widget _buildRecipeQuantitySelector() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.oldLace,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'Logging: ${_selectedRecipe!.title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    onPressed: () => setState(() => _quantity = (_quantity - 0.1).clamp(0.1, 10.0)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${_quantity.toStringAsFixed(1)} servings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    onPressed: () => setState(() => _quantity = (_quantity + 0.1).clamp(0.1, 10.0)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${(_selectedRecipe!.calories * _quantity).toInt()} kcal',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            ref.read(nutritionProvider.notifier).addCustomEntry(
              _selectedRecipe!.title, 
              (_selectedRecipe!.calories * _quantity).toInt(),
              _selectedRecipe!.protein * _quantity,
              _selectedRecipe!.carbs * _quantity,
              _selectedRecipe!.fats * _quantity,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 56)),
          child: const Text('Add to Log'),
        ),
      ],
    );
  }
}

// ── Support Widgets ──────────────────────────────────────────────────────────

class _FoodTile extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;

  const _FoodTile({required this.food, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: food.isHormoneFriendly
              ? AppColors.fertileGreen.withValues(alpha: 0.1)
              : AppColors.oldLace,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.restaurant_rounded,
            size: 18,
            color: food.isHormoneFriendly ? AppColors.fertileGreen : AppColors.textSecondary,
          ),
        ),
      ),
      title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${food.calories} kcal • P: ${food.protein.toStringAsFixed(0)}g • C: ${food.carbs.toStringAsFixed(0)}g • F: ${food.fats.toStringAsFixed(0)}g',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
    );
  }
}

class _NutrientPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _NutrientPill(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.mistySage.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.nudeRose.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.nudeRose),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
