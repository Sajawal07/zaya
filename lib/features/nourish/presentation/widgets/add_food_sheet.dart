import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_colors.dart';
import '../../../../providers/nutrition_provider.dart';
import '../../domain/models/recipe.dart';
import '../../data/repositories/recipe_repository.dart';
import 'package:zaya/models/nutrition_enums.dart';

enum AddFoodMode { options, custom, saved }

class AddFoodSheet extends ConsumerStatefulWidget {
  const AddFoodSheet({super.key});

  @override
  ConsumerState<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends ConsumerState<AddFoodSheet> {
  AddFoodMode _mode = AddFoodMode.options;
  final _formKey = GlobalKey<FormState>();
  
  // Custom Form fields
  String _customName = '';
  int _calories = 0;
  double _protein = 0;
  double _carbs = 0;
  double _fats = 0;

  // Saved Food fields
  String _searchQuery = '';
  Recipe? _selectedRecipe;
  double _quantity = 1.0;

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
    if (_mode == AddFoodMode.custom) title = 'Custom Entry';
    if (_mode == AddFoodMode.saved) title = 'Saved Foods';

    return Row(
      children: [
        if (_mode != AddFoodMode.options)
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => setState(() => _mode = AddFoodMode.options),
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
          icon: Icons.restaurant_rounded,
          title: 'Add Custom Meal',
          subtitle: 'Log a balanced meal manually',
          onTap: () => setState(() => _mode = AddFoodMode.custom),
        ),
        const SizedBox(height: 12),
        _OptionTile(
          icon: Icons.cookie_rounded,
          title: 'Add Quick Snack',
          subtitle: 'Log simple snacks and treats',
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
          
          if (totalMacros > 0) ...[
            const SizedBox(height: 24),
            _buildMacroDistribution(totalMacros),
          ],

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: !isValid ? null : () {
              if (_formKey.currentState!.validate()) {
                ref.read(nutritionProvider.notifier).addCustomEntry(
                  _customName, _calories, _protein, _carbs, _fats
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: isValid ? AppColors.nudeRose : AppColors.mistySage.withOpacity(0.3),
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
        color: AppColors.oldLace.withOpacity(0.5),
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
          _buildQuantitySelector(),
      ],
    );
  }

  Widget _buildQuantitySelector() {
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
          border: Border.all(color: AppColors.mistySage.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.nudeRose.withOpacity(0.1),
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
