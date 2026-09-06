import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/nutrition_log.dart';
import '../models/meal_plan.dart';
import 'package:hercycle_bloom/models/nutrition_enums.dart';
import 'database_provider.dart';
import 'pcos_provider.dart';
import '../features/nourish/domain/models/recipe.dart';
import '../features/nourish/data/repositories/recipe_repository.dart';
import '../features/health/domain/models/pcos_guidance.dart';
import '../features/nourish/domain/models/nutrition_models.dart';
import '../features/nourish/domain/services/nutrition_engine.dart';
import '../features/nourish/domain/services/meal_scoring_engine.dart';
import '../features/nourish/domain/services/macro_calculator.dart';

class NutritionState {
  final List<NutritionLog> todayLogs;
  final DailyMealPlan? currentPlan;
  final Recipe? breakfast;
  final Recipe? lunch;
  final Recipe? dinner;
  final List<Recipe> snacks;
  final bool isLoading;
  final NutritionSummary? summary;
  final int targetCalories;
  final List<double?> weeklyScores;

  NutritionState({
    required this.todayLogs,
    this.currentPlan,
    this.breakfast,
    this.lunch,
    this.dinner,
    this.snacks = const [],
    this.isLoading = false,
    this.summary,
    this.targetCalories = 2000,
    this.weeklyScores = const [],
  });

  NutritionState copyWith({
    List<NutritionLog>? todayLogs,
    DailyMealPlan? currentPlan,
    Recipe? breakfast,
    Recipe? lunch,
    Recipe? dinner,
    List<Recipe>? snacks,
    bool? isLoading,
    NutritionSummary? summary,
    int? targetCalories,
    List<double?>? weeklyScores,
  }) {
    return NutritionState(
      todayLogs: todayLogs ?? this.todayLogs,
      currentPlan: currentPlan ?? this.currentPlan,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snacks: snacks ?? this.snacks,
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      targetCalories: targetCalories ?? this.targetCalories,
      weeklyScores: weeklyScores ?? this.weeklyScores,
    );
  }
}

class NutritionNotifier extends StateNotifier<NutritionState> {
  final Ref ref;

  NutritionNotifier(this.ref) : super(NutritionState(todayLogs: [])) {
    _init();
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
      
      // Fetch user metrics for dynamic calorie goal
      final metrics = await db.getUserMetrics(user.uid);
      final targetCalories = (metrics?.dailyCalorieGoal ?? 2000).round();
      
      final logs = await db.getNutritionLogsForDate(user.uid, today);
      var plan = await db.getMealPlanForDate(user.uid, today);

      plan ??= await _generatePlan(user.uid, today);

      // Fetch weekly scores for the hormone-support chart
      final weeklyScores = await _fetchWeeklyScores(user.uid, today);

      _resolveRecipesAndSetState(logs, plan, targetCalories, weeklyScores);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<List<double?>> _fetchWeeklyScores(String userId, DateTime today) async {
    final db = ref.read(databaseServiceProvider);
    final scores = <double?>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayLogs = await db.getNutritionLogsForDate(userId, date);
      scores.add(NutritionEngine.calculateDayScore(dayLogs));
    }
    
    return scores;
  }

  Future<DailyMealPlan> _generatePlan(String userId, DateTime date) async {
    final pcosState = ref.read(pcosProvider).value;
    final primaryPattern = pcosState?.analysis?.pattern ?? PcosPattern.none;
    final scores = pcosState?.analysis?.patternScores ?? {};
    
    final activePatterns = scores.entries
        .where((e) => e.value >= 3.0)
        .map((e) => e.key)
        .toList();
    
    if (activePatterns.isEmpty) activePatterns.add(primaryPattern);

    final allRecipes = RecipeRepository.getAllRecipes();
    final recipes = allRecipes.where((r) => 
      r.categories.any((c) => activePatterns.contains(c))
    ).toList();

    Recipe pick(MealType type) {
      final typeMatch = recipes.where((r) => r.mealType == type).toList();
      if (typeMatch.isEmpty) return allRecipes.firstWhere((r) => r.mealType == type);
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

  void _resolveRecipesAndSetState(
    List<NutritionLog> logs,
    DailyMealPlan? plan,
    int targetCalories,
    List<double?> weeklyScores,
  ) {
    if (plan == null) {
      state = state.copyWith(
        todayLogs: logs, 
        isLoading: false,
        targetCalories: targetCalories,
        weeklyScores: weeklyScores,
        summary: NutritionEngine.calculateSummary(
          logs: logs,
          targetCalories: targetCalories,
        ),
      );
      return;
    }

    final allRecipes = RecipeRepository.getAllRecipes();
    final breakfast = allRecipes.firstWhere((r) => r.id == plan.breakfastRecipeId, orElse: () => allRecipes.first);
    final lunch = allRecipes.firstWhere((r) => r.id == plan.lunchRecipeId, orElse: () => allRecipes.first);
    final dinner = allRecipes.firstWhere((r) => r.id == plan.dinnerRecipeId, orElse: () => allRecipes.first);
    final snacks = allRecipes.where((r) => plan.snackRecipeIds.contains(r.id)).toList();

    final totalLogs = [...logs];
    final loggedTypes = plan.loggedMealTypes;

    if (!loggedTypes.contains(MealType.breakfast.name)) {
      totalLogs.add(_recipeTypeToLog(breakfast, MealType.breakfast, plan.breakfastPortion));
    }
    if (!loggedTypes.contains(MealType.lunch.name)) {
      totalLogs.add(_recipeTypeToLog(lunch, MealType.lunch, plan.lunchPortion));
    }
    if (!loggedTypes.contains(MealType.dinner.name)) {
      totalLogs.add(_recipeTypeToLog(dinner, MealType.dinner, plan.dinnerPortion));
    }

    state = state.copyWith(
      todayLogs: logs,
      currentPlan: plan,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      snacks: snacks,
      isLoading: false,
      targetCalories: targetCalories,
      weeklyScores: weeklyScores,
      summary: NutritionEngine.calculateSummary(
        logs: totalLogs,
        targetCalories: targetCalories,
      ),
    );
  }

  NutritionLog _recipeTypeToLog(Recipe r, MealType type, double portion) {
    return NutritionLog()
      ..itemName = r.title
      ..calories = (r.calories * portion).toInt()
      ..protein = r.protein * portion
      ..carbs = r.carbs * portion
      ..fats = r.fats * portion
      ..fiber = r.fiber * portion
      ..glycemicIndex = r.glycemicIndex
      ..pcosScore = MealScoringEngine.calculateMealScore(
        name: r.title,
        calories: r.calories * portion,
        protein: r.protein * portion,
        carbs: r.carbs * portion,
        fats: r.fats * portion,
        fiber: r.fiber * portion,
        glycemicIndex: r.glycemicIndex,
        glycemicLoad: MacroCalculator.calculateGlycemicLoad(r.glycemicIndex, r.carbs * portion),
        processingLevel: r.processingLevel,
      ).totalScore
      ..type = type;
  }

  Future<void> addCustomEntry(String name, int cal, double p, double c, double f, {
    double fiber = 0.0, 
    double gi = 50.0,
    double addedSugar = 0.0,
    double processingLevel = 0.5,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final score = MealScoringEngine.calculateMealScore(
      name: name,
      calories: cal.toDouble(),
      protein: p,
      carbs: c,
      fats: f,
      fiber: fiber,
      glycemicIndex: gi,
      glycemicLoad: MacroCalculator.calculateGlycemicLoad(gi, c),
      addedSugar: addedSugar,
      processingLevel: processingLevel,
    );

    final log = NutritionLog()
      ..userId = user.uid
      ..date = DateTime.now()
      ..itemName = name
      ..calories = cal
      ..protein = p
      ..carbs = c
      ..fats = f
      ..fiber = fiber
      ..glycemicIndex = gi
      ..pcosScore = score.totalScore
      ..type = MealType.custom
      ..isCustom = true;

    await ref.read(databaseServiceProvider).saveNutritionLog(log);
    _init(); 
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
    // Immediately rebuild state with updated portions for real-time UI update
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final db = ref.read(databaseServiceProvider);
    final logs = await db.getNutritionLogsForDate(user.uid, DateTime.now());
    final metrics = await db.getUserMetrics(user.uid);
    final targetCalories = (metrics?.dailyCalorieGoal ?? 2000).round();
    final weeklyScores = await _fetchWeeklyScores(user.uid, DateTime.now());
    _resolveRecipesAndSetState(logs, plan, targetCalories, weeklyScores);
  }

  Future<void> confirmMeal(MealType type, Recipe recipe, double portion) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || state.currentPlan == null) return;

    final plan = state.currentPlan!;
    if (plan.loggedMealTypes.contains(type.name)) return;

    final score = MealScoringEngine.calculateMealScore(
      name: recipe.title,
      calories: recipe.calories * portion,
      protein: recipe.protein * portion,
      carbs: recipe.carbs * portion,
      fats: recipe.fats * portion,
      fiber: recipe.fiber * portion,
      glycemicIndex: recipe.glycemicIndex,
      glycemicLoad: MacroCalculator.calculateGlycemicLoad(recipe.glycemicIndex, recipe.carbs * portion),
    );

    final log = NutritionLog()
      ..userId = user.uid
      ..date = DateTime.now()
      ..itemName = recipe.title
      ..calories = (recipe.calories * portion).toInt()
      ..protein = recipe.protein * portion
      ..carbs = recipe.carbs * portion
      ..fats = recipe.fats * portion
      ..fiber = recipe.fiber * portion
      ..glycemicIndex = recipe.glycemicIndex
      ..pcosScore = score.totalScore
      ..type = type
      ..isCustom = false;

    plan.loggedMealTypes = [...plan.loggedMealTypes, type.name];

    final db = ref.read(databaseServiceProvider);
    await db.saveNutritionLog(log);
    await db.saveMealPlan(plan);
    
    _init(); 
  }

  Future<void> regeneratePlan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final today = DateTime.now();
    await _generatePlan(user.uid, today);
    _init();
  }
}

final nutritionProvider = StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  ref.watch(databaseServiceProvider);
  return NutritionNotifier(ref);
});
