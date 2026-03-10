import 'package:flutter/material.dart';
import 'package:zaya/core/app_colors.dart';
import 'package:zaya/models/user_metrics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zaya/providers/database_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zaya/providers/metrics_provider.dart';

class MetricBottomSheet extends ConsumerStatefulWidget {
  final UserMetrics? initialMetrics;
  const MetricBottomSheet({super.key, this.initialMetrics});

  @override
  ConsumerState<MetricBottomSheet> createState() => _MetricBottomSheetState();
}

class _MetricBottomSheetState extends ConsumerState<MetricBottomSheet> {
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.initialMetrics?.weight?.toString() ?? '');
    _heightController = TextEditingController(text: widget.initialMetrics?.height?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update Body Metrics', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(_weightController.text);
              final height = double.tryParse(_heightController.text);
              
              if (weight != null && height != null) {
                final db = ref.read(databaseServiceProvider);
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final metrics = widget.initialMetrics ?? (UserMetrics()..userId = user.uid);
                  metrics.weight = weight;
                  metrics.height = height;
                  metrics.lastUpdated = DateTime.now();
                  await db.saveUserMetrics(metrics);
                  ref.invalidate(userMetricsProvider);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.nudeRose,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Save Metrics'),
          ),
        ],
      ),
    );
  }
}
