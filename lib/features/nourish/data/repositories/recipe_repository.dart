import '../../domain/models/recipe.dart';
import '../../../health/domain/models/pcos_guidance.dart';
import 'package:hercycle_bloom/models/nutrition_enums.dart';

class RecipeRepository {
  static List<Recipe> getAllRecipes() {
    return [
      // INSULIN RESISTANT focus
      Recipe(
        id: 'ir_1',
        title: 'Spinach & Feta Omelet',
        description: 'High protein breakfast to start the day right.',
        assetImagePath: 'assets/images/recipes/omelet.png',
        categories: [PcosPattern.insulinResistant, PcosPattern.lean],
        mealType: MealType.breakfast,
        calories: 350, protein: 24, carbs: 8, fats: 22,
        fiber: 2.5, glycemicIndex: 20, processingLevel: 0.2,
        ingredients: ['2 Eggs', '1 cup Spinach', '30g Feta Cheese'],
        instructions: ['Whisk eggs.', 'Sauté spinach.', 'Add eggs and feta.'],
        benefitNote: 'High protein helps stabilize blood sugar.',
        prepTimeMinutes: 15,
      ),
      Recipe(
        id: 'ir_2',
        title: 'Grilled Salmon Bowl',
        description: 'Omega-3 rich salmon with quinoa and avocado.',
        assetImagePath: 'assets/images/recipes/salmon.png',
        categories: [PcosPattern.insulinResistant, PcosPattern.inflammatory, PcosPattern.adrenal],
        mealType: MealType.lunch,
        calories: 550, protein: 42, carbs: 45, fats: 28,
        fiber: 12.0, glycemicIndex: 35, processingLevel: 0.1,
        ingredients: ['150g Salmon', '1/2 cup Quinoa', '1/2 Avocado'],
        instructions: ['Grill salmon.', 'Cook quinoa.', 'Assemble bowl.'],
        benefitNote: 'Omega-3s reduce inflammation and support hormonal balance.',
        prepTimeMinutes: 25,
      ),
      Recipe(
        id: 'ir_3',
        title: 'Lentil & Kale Soup',
        description: 'Fiber-rich and satisfying dinner.',
        assetImagePath: 'assets/images/recipes/soup.png',
        categories: [PcosPattern.insulinResistant, PcosPattern.inflammatory],
        mealType: MealType.dinner,
        calories: 400, protein: 18, carbs: 52, fats: 10,
        fiber: 15.0, glycemicIndex: 25, processingLevel: 0.1,
        ingredients: ['1 cup Lentils', '2 cups Kale', 'Onion'],
        instructions: ['Sauté onion.', 'Add lentils and broth.', 'Simmer then add kale.'],
        benefitNote: 'High fiber slows glucose absorption.',
        prepTimeMinutes: 40,
      ),
      Recipe(
        id: 'ir_4',
        title: 'Berry Chia Jam Toast',
        description: 'Slow-releasing energy snack.',
        assetImagePath: 'assets/images/recipes/avocado_toast_v2.png',
        categories: [PcosPattern.insulinResistant, PcosPattern.inflammatory],
        mealType: MealType.snack,
        calories: 220, protein: 8, carbs: 12, fats: 14,
        fiber: 8.0, glycemicIndex: 40, processingLevel: 0.3,
        ingredients: ['Sourdough', 'Chia jam', 'Berries'],
        instructions: ['Toast bread.', 'Spread jam.', 'Top with berries.'],
        benefitNote: 'Antioxidants and fiber for insulin stability.',
        prepTimeMinutes: 5,
      ),
      Recipe(
        id: 'ir_5',
        title: 'Turkey Lettuce Wraps',
        description: 'Low carb, high protein lunch.',
        assetImagePath: 'assets/images/recipes/garden_salad.png',
        categories: [PcosPattern.insulinResistant, PcosPattern.lean],
        mealType: MealType.lunch,
        calories: 320, protein: 35, carbs: 6, fats: 12,
        fiber: 3.0, glycemicIndex: 15, processingLevel: 0.2,
        ingredients: ['Ground turkey', 'Lettuce leaves', 'Bell peppers'],
        instructions: ['Cook turkey with spices.', 'Place in lettuce leaves.'],
        benefitNote: 'Excellent low-carb option for blood sugar control.',
        prepTimeMinutes: 20,
      ),

      // LEAN focus
      Recipe(
        id: 'lean_1',
        title: 'Avocado Toast & Eggs',
        description: 'Healthy fats for hormonal health.',
        assetImagePath: 'assets/images/recipes/avocado_toast.png',
        categories: [PcosPattern.lean, PcosPattern.adrenal],
        mealType: MealType.breakfast,
        calories: 420, protein: 18, carbs: 32, fats: 24,
        fiber: 9.0, glycemicIndex: 45, processingLevel: 0.2,
        ingredients: ['Sourdough', 'Avocado', '2 Eggs'],
        instructions: ['Toast bread.', 'Mash avocado.', 'Top with eggs.'],
        benefitNote: 'Supports fat-soluble vitamin absorption.',
        prepTimeMinutes: 10,
      ),
      Recipe(
        id: 'lean_2',
        title: 'Seared Salmon & Greens',
        description: 'Protein-packed heart-healthy meal.',
        assetImagePath: 'assets/images/recipes/salmon_bowl.png',
        categories: [PcosPattern.lean, PcosPattern.inflammatory],
        mealType: MealType.lunch,
        calories: 380, protein: 15, carbs: 48, fats: 12,
        fiber: 10.0, glycemicIndex: 30, processingLevel: 0.1,
        ingredients: ['Salmon', 'Mixed greens', 'Lemon'],
        instructions: ['Sear salmon.', 'Toss greens.', 'Serve together.'],
        benefitNote: 'High in micronutrients for lean PCOS care.',
        prepTimeMinutes: 35,
      ),

      // INFLAMMATORY focus
      Recipe(
        id: 'inf_1',
        title: 'Turmeric Garden Omelet',
        description: 'Anti-inflammatory breakfast.',
        assetImagePath: 'assets/images/recipes/omelet_v3.png',
        categories: [PcosPattern.inflammatory, PcosPattern.adrenal],
        mealType: MealType.breakfast,
        calories: 320, protein: 10, carbs: 45, fats: 10,
        fiber: 4.0, glycemicIndex: 25, processingLevel: 0.2,
        ingredients: ['Eggs', 'Turmeric', 'Spinach'],
        instructions: ['Whisk eggs with turmeric.', 'Sauté spinach.', 'Cook omelet.'],
        benefitNote: 'Curcumin reduces systemic inflammation.',
        prepTimeMinutes: 10,
      ),
      Recipe(
        id: 'inf_2',
        title: 'Salmon & Broccoli Salad',
        description: 'Rich in antioxidants.',
        assetImagePath: 'assets/images/recipes/salmon.png',
        categories: [PcosPattern.inflammatory, PcosPattern.insulinResistant],
        mealType: MealType.lunch,
        calories: 340, protein: 12, carbs: 22, fats: 24,
        fiber: 6.0, glycemicIndex: 15, processingLevel: 0.1,
        ingredients: ['Salmon', 'Broccoli', 'Olive oil'],
        instructions: ['Sear salmon.', 'Steam broccoli.', 'Toss with oil.'],
        benefitNote: 'Omega-3 reduces systemic inflammation.',
        prepTimeMinutes: 15,
      ),

      // ADRENAL / POST-PILL focus
      Recipe(
        id: 'adr_1',
        title: 'Golden Sweet Potato Mash',
        description: 'Adrenal support breakfast.',
        assetImagePath: 'assets/images/recipes/omelet.png',
        categories: [PcosPattern.adrenal, PcosPattern.postPill, PcosPattern.insulinResistant],
        mealType: MealType.breakfast,
        calories: 380, protein: 12, carbs: 50, fats: 14,
        fiber: 7.0, glycemicIndex: 50, processingLevel: 0.2,
        ingredients: ['Sweet potato', 'Spinach', '1 Egg'],
        instructions: ['Dice and sauté potato.', 'Add spinach and egg.'],
        benefitNote: 'Complex carbs support stable cortisol levels.',
        prepTimeMinutes: 20,
      ),
      Recipe(
        id: 'gen_1',
        title: 'Classic Garden Salad',
        description: 'Light and fresh.',
        assetImagePath: 'assets/images/recipes/garden_salad.png',
        categories: [PcosPattern.none, PcosPattern.inflammatory, PcosPattern.lean],
        mealType: MealType.lunch,
        calories: 220, protein: 4, carbs: 12, fats: 18,
        fiber: 5.0, glycemicIndex: 15, processingLevel: 0.1,
        ingredients: ['Mixed greens', 'Cucumber', 'Radish'],
        instructions: ['Toss all with vinegar dressing.'],
        benefitNote: 'Simple micronutrient boost.',
        prepTimeMinutes: 10,
      ),
    ];
  }

  static List<Recipe> getRecipesByPattern(PcosPattern pattern) {
    final all = getAllRecipes();
    final filtered = all.where((r) => r.categories.contains(pattern)).toList();
    if (filtered.isEmpty) {
      return all.where((r) => r.categories.contains(PcosPattern.none)).toList();
    }
    return filtered;
  }
}
