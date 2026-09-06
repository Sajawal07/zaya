import 'package:flutter/material.dart';
import 'package:hercycle_bloom/features/health/presentation/screens/health_hub_screen.dart';
import '../../../../core/app_colors.dart';

/// Pregnancy-specific health hub: symptom guide, safe foods, nutrition tips,
/// and weight guidance.
class PregnancyHealthScreen extends StatelessWidget {
  const PregnancyHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Health',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const Text('Take care of you and baby',
                                  style: TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.health_and_safety_outlined, color: AppColors.nudeRose),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthHubScreen())),
                        ),
                      ],
                    ),
              ),
            ),

            // ── Quick Action Cards ──────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(child: _QuickCard(icon: Icons.restaurant_menu_rounded, label: 'Nutrition', color: const Color(0xFF4A9373), onTap: () {})),
                    const SizedBox(width: 12),
                    Expanded(child: _QuickCard(icon: Icons.monitor_weight_outlined, label: 'Weight', color: AppColors.nudeRose, onTap: () {})),
                    const SizedBox(width: 12),
                    Expanded(child: _QuickCard(icon: Icons.medical_information_outlined, label: 'Symptoms', color: AppColors.pregnancyGold, onTap: () {})),
                  ],
                ),
              ),
            ),

            // ── Safe Foods ──────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              sliver: SliverToBoxAdapter(
                child: const Text('Safe & Avoid Foods', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              sliver: SliverToBoxAdapter(child: _SafeFoodsCard()),
            ),

            // ── Nutrition Highlights ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              sliver: SliverToBoxAdapter(
                child: const Text('Key Nutrients This Trimester', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              sliver: SliverToBoxAdapter(child: _NutrientGrid()),
            ),

            // ── Exercise Tips ───────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              sliver: SliverToBoxAdapter(
                child: const Text('Pregnancy-Safe Exercise', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              sliver: SliverToBoxAdapter(child: _ExerciseList()),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SafeFoodsCard extends StatelessWidget {
  final _safe = const [
    ('Leafy greens', '🥬', 'Folate & iron'),
    ('Salmon', '🐟', 'Omega-3 DHA'),
    ('Eggs', '🥚', 'Choline & protein'),
    ('Legumes', '🫘', 'Fiber & folate'),
    ('Sweet potato', '🍠', 'Vitamin A & C'),
  ];

  final _avoid = const [
    ('Raw fish / sushi', '🚫', 'Bacteria risk'),
    ('Unpasteurised cheese', '🚫', 'Listeria risk'),
    ('High-mercury fish', '🚫', 'Neurotoxic'),
    ('Raw / undercooked meat', '🚫', 'Toxoplasma'),
    ('Alcohol', '🚫', 'No safe level'),
  ];

  const _SafeFoodsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _sectionHeader('✅ Eat More', AppColors.fertileGreen),
          const SizedBox(height: 8),
          ..._safe.map((f) => _foodRow(f.$1, f.$2, f.$3, AppColors.fertileGreen)),
          const Divider(height: 24),
          _sectionHeader('⚠️ Avoid', AppColors.error),
          const SizedBox(height: 8),
          ..._avoid.map((f) => _foodRow(f.$1, f.$2, f.$3, AppColors.error)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _foodRow(String name, String emoji, String note, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(note, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}

class _NutrientGrid extends StatelessWidget {
  final _nutrients = const [
    ('Folate', '600 mcg/day', Icons.eco_rounded, Color(0xFF4A9373)),
    ('Iron', '27 mg/day', Icons.bloodtype_rounded, Color(0xFFE57373)),
    ('Calcium', '1000 mg/day', Icons.water_drop_outlined, Color(0xFF42A5F5)),
    ('DHA', '200 mg/day', Icons.waves_rounded, Color(0xFF26C6DA)),
    ('Vitamin D', '600 IU/day', Icons.wb_sunny_outlined, Color(0xFFFFCA28)),
    ('Protein', '+25g/day', Icons.fitness_center_rounded, AppColors.nudeRose),
  ];

  const _NutrientGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: _nutrients.map((n) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(n.$3, color: n.$4, size: 20),
            const SizedBox(height: 6),
            Text(n.$1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 2),
            Text(n.$2, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      )).toList(),
    );
  }
}

class _ExerciseList extends StatelessWidget {
  final _exercises = const [
    ('Walking', '30 min daily — keeps energy up and reduces swelling', Icons.directions_walk_rounded),
    ('Prenatal Yoga', 'Reduces back pain and prepares body for labour', Icons.self_improvement_rounded),
    ('Swimming', 'Low-impact; relieves joint pressure in 2nd & 3rd trimester', Icons.pool_rounded),
    ('Pelvic Floor', '3 sets of 10 Kegels daily — crucial for recovery', Icons.accessibility_rounded),
  ];

  const _ExerciseList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _exercises.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4A9373).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(e.$3, color: const Color(0xFF4A9373), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(e.$2, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}
