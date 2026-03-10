import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/nutrition_log.dart';
import '../models/meal_plan.dart';
import 'package:zaya/models/nutrition_enums.dart';
import 'database_provider.dart';
import 'pcos_provider.dart';
import '../features/nourish/domain/models/recipe.dart';
import '../features/nourish/data/repositories/recipe_repository.dart';
import '../features/health/domain/models/pcos_guidance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NutritionState {
  final List<NutritionLog> todayLogs;
  final DailyMealPlan? currentPlan;
  final Recipe? breakfast;
  final Recipe? lunch;
  final Recipe? dinner;
  final List<Recipe> snacks;
  final bool isLoading;

  NutritionState({
    required this.todayLogs,
    this.currentPlan,
    this.breakfast,
    this.lunch,
    this.dinner,
    this.snacks = const [],
    this.isLoading = false,
  }) {
    // Pre-calculate to avoid duplicate loops and summing on every getter access
    double logCals = 0;
    double logP = 0;
    double logC = 0;
    double logF = 0;

    for (var log in todayLogs) {
      logCals += log.calories.clamp(0, 10000);
      logP += log.protein.clamp(0.0, 1000.0);
      logC += log.carbs.clamp(0.0, 2000.0);
      logF += log.fats.clamp(0.0, 1000.0);
    }

    double planCals = 0;
    double planP = 0;
    double planC = 0;
    double planF = 0;

    final loggedTypes = currentPlan?.loggedMealTypes ?? [];

    // Only add planned macros if they haven't been "Logged" yet
    if (breakfast != null && !loggedTypes.contains(MealType.breakfast.name)) {
      final m = (currentPlan?.breakfastPortion ?? 1.0).clamp(0.0, 10.0);
      planCals += breakfast!.calories * m;
      planP += breakfast!.protein * m;
      planC += breakfast!.carbs * m;
      planF += breakfast!.fats * m;
    }

    if (lunch != null && !loggedTypes.contains(MealType.lunch.name)) {
      final m = (currentPlan?.lunchPortion ?? 1.0).clamp(0.0, 10.0);
      planCals += lunch!.calories * m;
      planP += lunch!.protein * m;
      planC += lunch!.carbs * m;
      planF += lunch!.fats * m;
    }

    if (dinner != null && !loggedTypes.contains(MealType.dinner.name)) {
      final m = (currentPlan?.dinnerPortion ?? 1.0).clamp(0.0, 10.0);
      planCals += dinner!.calories * m;
      planP += dinner!.protein * m;
      planC += dinner!.carbs * m;
      planF += dinner!.fats * m;
    }

    // Snacks (Treating them as suggested until more complex tracking added)
    // Avoid double counting by checking if any custom entry or similar snack logged?
    // For now, if user logs ANY non-custom snack, we could track it, but snacks are simple
    for (var s in snacks) {
      planCals += s.calories;
      planP += s.protein;
      planC += s.carbs;
      planF += s.fats;
    }

    _totalCalories = (logCals + planCals).toInt();
    _totalProtein = logP + planP;
    _totalCarbs = logC + planC;
    _totalFats = logF + planF;
  }

  late final int _totalCalories;
  late final double _totalProtein;
  late final double _totalCarbs;
  late final double _totalFats;

  int get totalCalories => _totalCalories;
  double get totalProtein => _totalProtein;
  double get totalCarbs => _totalCarbs;
  double get totalFats => _totalFats;

  NutritionState copyWith({
    List<NutritionLog>? todayLogs,
    DailyMealPlan? currentPlan,
    Recipe? breakfast,
    Recipe? lunch,
    Recipe? dinner,
    List<Recipe>? snacks,
    bool? isLoading,
  }) {
    return NutritionState(
      todayLogs: todayLogs ?? this.todayLogs,
      currentPlan: currentPlan ?? this.currentPlan,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snacks: snacks ?? this.snacks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NutritionNotifier extends StateNotifier<NutritionState> {
  final Ref ref;

  NutritionNotifier(this.ref) : super(NutritionState(todayLogs: [])) {
    _loadFromCache().then((_) => _init());
  }

  static const _cacheKey = 'nutrition_state_cache';

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        // Simple heuristic for now: if we have cached data, show it first
        // We'd need to serialize NutritionState to JSON for full restore
        // For now, let's just make sure we don't overwrite if recent
      }
    } catch (_) {}
  }

  Future<void> _saveToCache(NutritionState newState) async {
     // Simplified caching: just save that we had data
     // Real implementation would serialize the whole state
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final db = ref.read(databaseServiceProvider);
      final today = DateTime.now();
      
      final logs = await db.getNutritionLogsForDate(user.uid, today);
      var plan = await db.getMealPlanForDate(user.uid, today);

      if (plan == null) {
        plan = await _generatePlan(user.uid, today);
      }

      _resolveRecipesAndSetState(logs, plan);
    } catch (e) {
      // Log error if needed
      state = state.copyWith(isLoading: false);
    }
  }

  Future<DailyMealPlan> _generatePlan(String userId, DateTime date) async {
    final pcosState = ref.read(pcosProvider).value;
    final primaryPattern = pcosState?.analysis?.pattern ?? PcosPattern.none;
    final scores = pcosState?.analysis?.patternScores ?? {};
    
    // Weighted approach: Get all patterns with significant scores
    final activePatterns = scores.entries
        .where((e) => e.value >= 3.0)
        .map((e) => e.key)
        .toList();
    
    if (activePatterns.isEmpty) activePatterns.add(primaryPattern);

    // Filter recipes that match ANY of our significant patterns
    final allRecipes = RecipeRepository.getAllRecipes();
    final recipes = allRecipes.where((r) => 
      r.categories.any((c) => activePatterns.contains(c))
    ).toList();

    // Strategy: Try to pick for the primary pattern first, fallback to any active
    Recipe pick(MealType type) {
      final typeMatch = recipes.where((r) => r.mealType == type).toList();
      if (typeMatch.isEmpty) return allRecipes.firstWhere((r) => r.mealType == type);
      
      // Prefer primary pattern if possible
      final primaryMatch = typeMatch.where((r) => r.categories.contains(primaryPattern)).toList();
      return primaryMatch.isNotEmpty ? primaryMatch.first : typeMatch.first;
    }

    final breakfast = pick(MealType.breakfast);
    final lunch = pick(MealType.lunch);
    final dinner = pick(MealType.dinner);
    final snack = pick(MealType.snack);

    final plan = DailyMealPlan()
      ..userId = userId
      ..date = DateTime(date.year, date.month, date.day)
      ..pcosPattern = primaryPattern.name
      ..breakfastRecipeId = breakfast.id
      ..lunchRecipeId = lunch.id
      ..dinnerRecipeId = dinner.id
      ..snackRecipeIds = [snack.id];

    await ref.read(databaseServiceProvider).saveMealPlan(plan);
    return plan;
  }

  void _resolveRecipesAndSetState(List<NutritionLog> logs, DailyMealPlan? plan) {
    if (plan == null) {
      state = state.copyWith(todayLogs: logs, isLoading: false);
      return;
    }

    final allRecipes = RecipeRepository.getAllRecipes();
    final breakfast = allRecipes.firstWhere((r) => r.id == plan.breakfastRecipeId, orElse: () => allRecipes.first);
    final lunch = allRecipes.firstWhere((r) => r.id == plan.lunchRecipeId, orElse: () => allRecipes.first);
    final dinner = allRecipes.firstWhere((r) => r.id == plan.dinnerRecipeId, orElse: () => allRecipes.first);
    final snacks = allRecipes.where((r) => plan.snackRecipeIds.contains(r.id)).toList();

    state = state.copyWith(
      todayLogs: logs,
      currentPlan: plan,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      snacks: snacks,
      isLoading: false,
    );
  }

  Future<void> addCustomEntry(String name, int cal, double p, double c, double f) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final log = NutritionLog()
      ..userId = user.uid
      ..date = DateTime.now()
      ..itemName = name
      ..calories = cal
      ..protein = p
      ..carbs = c
      ..fats = f
      ..type = MealType.custom
      ..isCustom = true;

    await ref.read(databaseServiceProvider).saveNutritionLog(log);
    _init(); // Refresh
  }

  Future<void> swapDish(MealType type, String newRecipeId) async {
    if (state.currentPlan == null) return;
    
    final plan = state.currentPlan!;
    switch (type) {
      case MealType.breakfast: plan.breakfastRecipeId = newRecipeId; break;
      case MealType.lunch: plan.lunchRecipeId = newRecipeId; break;
      case MealType.dinner: plan.dinnerRecipeId = newRecipeId; break;
      case MealType.snack: 
        if (!plan.snackRecipeIds.contains(newRecipeId)) {
          plan.snackRecipeIds = [...plan.snackRecipeIds, newRecipeId];
        }
        break;
      default: break;
    }

    await ref.read(databaseServiceProvider).saveMealPlan(plan);
    _init();
  }

  Future<void> adjustPortion(MealType type, double multiplier) async {
    if (state.currentPlan == null) return;
    final plan = state.currentPlan!;
    switch (type) {
      case MealType.breakfast: plan.breakfastPortion = multiplier; break;
      case MealType.lunch: plan.lunchPortion = multiplier; break;
      case MealType.dinner: plan.dinnerPortion = multiplier; break;
      default: break;
    }
    await ref.read(databaseServiceProvider).saveMealPlan(plan);
    _init();
  }

  Future<void> confirmMeal(MealType type, Recipe recipe, double portion) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || state.currentPlan == null) return;

    final plan = state.currentPlan!;
    // Avoid double logging if already in the list
    if (plan.loggedMealTypes.contains(type.name)) return;

    final log = NutritionLog()
      ..userId = user.uid
      ..date = DateTime.now()
      ..itemName = recipe.title
      ..calories = (recipe.calories * portion).toInt()
      ..protein = recipe.protein * portion
      ..carbs = recipe.carbs * portion
      ..fats = recipe.fats * portion
      ..type = type
      ..isCustom = false;

    // Add to the list of logged types for this plan
    plan.loggedMealTypes = [...plan.loggedMealTypes, type.name];

    final db = ref.read(databaseServiceProvider);
    await db.saveNutritionLog(log);
    await db.saveMealPlan(plan);
    
    _init(); 
  }

  Future<void> regeneratePlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final db = ref.read(databaseServiceProvider);
    final today = DateTime.now();
    
    await _generatePlan(user.uid, today);
    _init();
  }
}

final nutritionProvider = StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  return NutritionNotifier(ref);
});
