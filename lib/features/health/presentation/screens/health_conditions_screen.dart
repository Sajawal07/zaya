import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/providers/metrics_provider.dart';
import 'package:hercycle_bloom/models/user_metrics.dart';
import 'package:hercycle_bloom/providers/database_provider.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';

class HealthConditionsScreen extends ConsumerStatefulWidget {
  const HealthConditionsScreen({super.key});

  @override
  ConsumerState<HealthConditionsScreen> createState() => _HealthConditionsScreenState();
}

class _HealthConditionsScreenState extends ConsumerState<HealthConditionsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(userMetricsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Health Conditions', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: metricsAsync.when(
        data: (metrics) {
          if (metrics == null) return const Center(child: Text('No metrics found'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select any conditions you\'ve been diagnosed with or would like to track.',
                  style: GoogleFonts.montserrat(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),
                _buildConditionTile(
                  title: 'Polycystic Ovary Syndrome (PCOS)',
                  subtitle: 'Includes insulin resistance and hormone balance tracking',
                  value: metrics.healthMode == HealthMode.pcos,
                  onChanged: (v) {
                     metrics.healthMode = v ? HealthMode.pcos : HealthMode.standard;
                     _save(metrics);
                  },
                ),
                const SizedBox(height: 12),
                _buildConditionTile(
                  title: 'Endometriosis',
                  subtitle: 'Track chronic pain patterns and flare-ups',
                  value: metrics.hasEndometriosis,
                  onChanged: (v) {
                    metrics.hasEndometriosis = v;
                    _save(metrics);
                  },
                ),
                const SizedBox(height: 12),
                _buildConditionTile(
                  title: 'PMDD',
                  subtitle: 'Premenstrual Dysphoric Disorder mood support',
                  value: metrics.hasPMDD,
                  onChanged: (v) {
                    metrics.hasPMDD = v;
                    _save(metrics);
                  },
                ),
                const SizedBox(height: 12),
                _buildConditionTile(
                  title: 'Thyroid Disorder',
                  subtitle: 'Monitor fatigue and metabolic changes',
                  value: metrics.hasThyroid,
                  onChanged: (v) {
                    metrics.hasThyroid = v;
                    _save(metrics);
                  },
                ),
                const SizedBox(height: 12),
                _buildConditionTile(
                  title: 'Fibroids & Polyps',
                  subtitle: 'Flow intensity and pain tracking',
                  value: metrics.hasFibroids,
                  onChanged: (v) {
                    metrics.hasFibroids = v;
                    _save(metrics);
                  },
                ),
                const SizedBox(height: 12),
                _buildConditionTile(
                  title: 'Amenorrhea',
                  subtitle: 'Absence or irregular periods',
                  value: metrics.hasAmenorrhea,
                  onChanged: (v) {
                    metrics.hasAmenorrhea = v;
                    _save(metrics);
                  },
                ),
                const SizedBox(height: 48),
                if (_isLoading) const AppLoaderCentered(),
              ],
            ),
          );
        },
        loading: () => const AppLoaderCentered(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildConditionTile({required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: value ? AppColors.nudeRose : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        activeColor: AppColors.nudeRose,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Future<void> _save(UserMetrics metrics) async {
    setState(() => _isLoading = true);
    await ref.read(databaseServiceProvider).saveUserMetrics(metrics);
    ref.invalidate(userMetricsProvider);
    if (mounted) setState(() => _isLoading = false);
  }
}
