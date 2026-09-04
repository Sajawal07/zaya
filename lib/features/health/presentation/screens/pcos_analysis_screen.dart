import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_colors.dart';
import '../../../../providers/pcos_provider.dart';
import '../../domain/models/pcos_guidance.dart';
import '../../domain/services/pcos_analyzer.dart';
import '../../../../shared/widgets/app_loader.dart';

class PcosAnalysisScreen extends ConsumerWidget {
  const PcosAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pcosState = ref.watch(pcosProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Hormonal Profile'),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: pcosState.when(
        loading: () => const AppLoaderCentered(),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) => _buildContent(context, ref, state),
      ),
      bottomNavigationBar: _buildSaveButton(context, ref, pcosState),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, PcosState state) {
    final analysis = state.analysis;
    final guidance = analysis != null ? PcosGuidance.getGuidance(analysis.pattern) : null;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDisclaimer(),
                const SizedBox(height: 32),
                Text(
                  'Your Symptoms',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select any symptoms you have been experiencing lately.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                _buildSymptomGrid(ref, state),
                const SizedBox(height: 40),
                if (analysis != null && analysis.pattern != PcosPattern.none) ...[
                  _buildAnalysisResult(context, analysis, guidance!),
                  const SizedBox(height: 100),
                ] else ...[
                  _buildEmptyState(context),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is not a medical diagnosis. Please consult a healthcare professional for proper evaluation.',
              style: TextStyle(
                color: AppColors.error.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomGrid(WidgetRef ref, PcosState state) {
    final m = state.metrics;
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: [
        _SymptomChip(
          label: 'Irregular Periods',
          isSelected: m.irregularPeriods,
          onSelected: (v) => ref.read(pcosProvider.notifier).updateSymptom('irregularPeriods', v),
        ),
        _SymptomChip(
          label: 'Sugar Cravings',
          isSelected: m.sugarCravings,
          onSelected: (v) => ref.read(pcosProvider.notifier).updateSymptom('sugarCravings', v),
        ),
        _SymptomChip(
          label: 'Acne',
          isSelected: m.acne,
          onSelected: (v) => ref.read(pcosProvider.notifier).updateSymptom('acne', v),
        ),
        _SymptomChip(
          label: 'Hair Fall',
          isSelected: m.hairFall,
          onSelected: (v) => ref.read(pcosProvider.notifier).updateSymptom('hairFall', v),
        ),
        _SymptomChip(
          label: 'Facial Hair',
          isSelected: m.facialHair,
          onSelected: (v) => ref.read(pcosProvider.notifier).updateSymptom('facialHair', v),
        ),
        _SymptomChip(
          label: 'Fatigue',
          isSelected: m.fatigue,
          onSelected: (v) => ref.read(pcosProvider.notifier).updateSymptom('fatigue', v),
        ),
        _SymptomChip(
          label: 'Brain Fog',
          isSelected: m.brainFog,
          onSelected: (v) => ref.read(pcosProvider.notifier).updateSymptom('brainFog', v),
        ),
        _SymptomChip(
          label: 'Anxiety',
          isSelected: m.anxiety,
          onSelected: (v) => ref.read(pcosProvider.notifier).updateSymptom('anxiety', v),
        ),
        _SymptomChip(
          label: 'Sleep Issues',
          isSelected: m.sleepIssues,
          onSelected: (v) => ref.read(pcosProvider.notifier).updateSymptom('sleepIssues', v),
        ),
        _SymptomChip(
          label: 'Stopped Pill Recently',
          isSelected: m.recentlyStoppedPill,
          onSelected: (v) => ref.read(pcosProvider.notifier).updateSymptom('recentlyStoppedPill', v),
        ),
      ],
    );
  }

  Widget _buildAnalysisResult(BuildContext context, PcosAnalysis analysis, PcosGuidance guidance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.mistySage.withValues(alpha: 0.2), height: 20),
        Text(
          'Analysis Result',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.oldLace,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.nudeRose.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                guidance.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.nudeRose),
              ),
              const SizedBox(height: 8),
              Text(
                analysis.suggestion,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                guidance.coreProblem,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildGuidanceSection(context, 'Recommended Foods', guidance.recommendedFoods, Icons.restaurant_menu_rounded),
        const SizedBox(height: 24),
        _buildGuidanceSection(context, 'Lifestyle Support', guidance.lifestyle, Icons.auto_awesome_rounded),
      ],
    );
  }

  Widget _buildGuidanceSection(BuildContext context, String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.mistySage, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: CircleAvatar(radius: 3, backgroundColor: AppColors.nudeRose),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.analytics_outlined, size: 64, color: AppColors.mistySage.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Select your symptoms to see analysis',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget? _buildSaveButton(BuildContext context, WidgetRef ref, AsyncValue<PcosState> state) {
    return state.when(
      data: (s) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: ElevatedButton(
          onPressed: () async {
            await ref.read(pcosProvider.notifier).save();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Insights saved successfully')),
              );
            }
          },
          child: const Text('Save My Insights'),
        ),
      ),
      loading: () => null,
      error: (_, __) => null,
    );
  }
}


class _SymptomChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const _SymptomChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.nudeRose.withValues(alpha: 0.2),
      checkmarkColor: AppColors.nudeRose,
      backgroundColor: AppColors.white,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.nudeRose : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.nudeRose : AppColors.mistySage.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
