import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hercycle_bloom/providers/metrics_provider.dart';
import 'package:hercycle_bloom/shared/widgets/app_loader.dart';
import '../screens/health_metrics_setup_screen.dart';

class HealthGateWrapper extends ConsumerWidget {
  final Widget child;
  const HealthGateWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(userMetricsProvider);

    return metricsAsync.when(
      data: (metrics) {
        if (metrics == null || !metrics.isMetricsComplete) {
          return const HealthMetricsSetupScreen();
        }
        return child;
      },
      loading: () => const Scaffold(body: AppLoaderCentered()),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
