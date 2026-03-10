enum PcosPattern {
  insulinResistant,
  lean,
  inflammatory,
  adrenal,
  postPill,
  none
}

class PcosGuidance {
  final PcosPattern pattern;
  final String title;
  final String coreProblem;
  final String dietGoal;
  final List<String> focus;
  final List<String> recommendedFoods;
  final List<String> helpfulAdditions;
  final List<String> avoidFoods;
  final List<String> lifestyle;

  PcosGuidance({
    required this.pattern,
    required this.title,
    required this.coreProblem,
    required this.dietGoal,
    required this.focus,
    required this.recommendedFoods,
    required this.helpfulAdditions,
    required this.avoidFoods,
    required this.lifestyle,
  });

  static PcosGuidance getGuidance(PcosPattern pattern) {
    switch (pattern) {
      case PcosPattern.insulinResistant:
        return PcosGuidance(
          pattern: pattern,
          title: "Insulin-Resistant PCOS",
          coreProblem: "High insulin levels",
          dietGoal: "Stabilize blood sugar, reduce insulin spikes, and promote healthy metabolism.",
          focus: ["High protein", "Low glycemic index carbs", "Anti-sugar approach"],
          recommendedFoods: [
            "High-protein: Eggs, Chicken, Fish, Lentils",
            "Low-GI carbs: Oats, Brown rice, Quinoa",
            "Healthy fats: Avocado, Nuts, Olive oil",
            "Green veg: Spinach, Broccoli, Cucumber"
          ],
          helpfulAdditions: [
            "Cinnamon (improves insulin sensitivity)",
            "Apple cider vinegar (before meals)",
            "Green tea",
            "Walk 10 mins after meals"
          ],
          avoidFoods: ["Sugary drinks", "White bread", "Sweets", "Refined flour"],
          lifestyle: ["Regular strength training", "Consistent meal timing", "Avoid late-night snacking"],
        );
      case PcosPattern.lean:
        return PcosGuidance(
          pattern: pattern,
          title: "Lean PCOS",
          coreProblem: "Hormonal imbalance (not weight driven)",
          dietGoal: "Balance hormones, support metabolism, and prevent nutrient deficiencies.",
          focus: ["Balanced macros", "Hormone support", "Nutrient density"],
          recommendedFoods: [
            "Balanced meals (Protein + Fat + Complex Carbs)",
            "Eggs with whole-grain toast",
            "Chicken with quinoa",
            "Full-fat yogurt with nuts and seeds"
          ],
          helpfulAdditions: [
            "Spearmint tea (reduces excess androgens)",
            "Flaxseeds",
            "Pumpkin seeds",
            "Walnuts and Fatty fish (Omega-3)"
          ],
          avoidFoods: ["Skipping meals", "Extreme dieting", "Very low-carb diets"],
          lifestyle: ["Stress control", "Moderate exercise", "Priority on sleep quality"],
        );
      case PcosPattern.inflammatory:
        return PcosGuidance(
          pattern: pattern,
          title: "Inflammatory PCOS",
          coreProblem: "Chronic inflammation",
          dietGoal: "Reduce inflammation, improve gut health, and stabilize energy.",
          focus: ["Anti-inflammatory approach", "Gut health support", "Whole foods"],
          recommendedFoods: [
            "Leafy greens and Dark berries",
            "Healthy fats: Olive oil, Nuts, Seeds",
            "Fermented foods: Yogurt, Kefir, Pickled vegetables",
            "Ginger and Turmeric"
          ],
          helpfulAdditions: [
            "Turmeric milk (Golden Milk)",
            "Green tea",
            "Ginger tea",
            "Omega-3 fatty acids"
          ],
          avoidFoods: ["Processed and Fried food", "Excess sugar", "Packaged snacks"],
          lifestyle: ["Gentle movement", "Prioritize 7-9 hours of sleep", "Reduce environmental toxins"],
        );
      case PcosPattern.adrenal:
        return PcosGuidance(
          pattern: pattern,
          title: "Adrenal PCOS",
          coreProblem: "High cortisol from stress",
          dietGoal: "Support adrenal glands, stabilize energy, and reduce stress response.",
          focus: ["Nervous system support", "Cortisol regulation", "Magnesium focus"],
          recommendedFoods: [
            "Complex carbs: Sweet potatoes, Oats, Brown rice",
            "Magnesium-rich: Spinach, Almonds, Dark chocolate (70%+)",
            "Regular, balanced meals to avoid blood sugar drops"
          ],
          helpfulAdditions: [
            "Chamomile tea",
            "Warm herbal teas",
            "Magnesium-rich snacks",
            "Yoga and Meditation"
          ],
          avoidFoods: ["Excess caffeine", "Energy drinks", "Skipping meals", "Very low-calorie diets"],
          lifestyle: ["Stress reduction", "Relaxing bedtime routine", "Avoid over-training"],
        );
      case PcosPattern.postPill:
        return PcosGuidance(
          pattern: pattern,
          title: "Post-Pill PCOS",
          coreProblem: "Temporary hormonal transition",
          dietGoal: "Support natural hormone production and replenish key nutrients.",
          focus: ["Hormonal recovery", "Ovulation support", "Micronutrient focus"],
          recommendedFoods: [
            "Zinc-rich: Pumpkin seeds, Chickpeas, Eggs",
            "B-vitamin foods: Whole grains, Leafy greens",
            "Healthy fats: Avocado, Nuts, Seeds",
            "Liver support: Beets, Lemon water"
          ],
          helpfulAdditions: [
            "Spearmint tea",
            "Flaxseeds",
            "Adequate hydration",
            "Gentle herbal support"
          ],
          avoidFoods: ["Processed foods", "Alcohol", "Excess sugar"],
          lifestyle: ["Hormonal recovery tracking", "Patience with results", "Gentle lifestyle shifts"],
        );
      case PcosPattern.none:
        return PcosGuidance(
          pattern: pattern,
          title: "Balanced Wellness",
          coreProblem: "General health maintenance",
          dietGoal: "Maintain hormonal balance and metabolic health.",
          focus: ["Whole foods", "Hydration", "Balanced meals"],
          recommendedFoods: ["Diverse vegetables", "Lean proteins", "Complex carbohydrates"],
          helpfulAdditions: ["Regular hydration", "Fiber-rich snacks"],
          avoidFoods: ["Ultra-processed foods", "High-sugar snacks"],
          lifestyle: ["Regular activity", "Sleep hygiene"],
        );
    }
  }
}
