import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'metrics_provider.dart';

// Pregnancy mode is derived from UserMetrics
final pregnancyModeProvider = Provider<bool>((ref) {
  final metrics = ref.watch(userMetricsProvider).value;
  return metrics?.isPregnant ?? false;
});
