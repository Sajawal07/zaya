import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/metrics_provider.dart';

/// The two mutually-exclusive experience modes of the HerCycle Bloom app.
enum AppMode { cycle, pregnancy }

/// Derives the active mode from [UserMetrics.isPregnant].
/// This is the single source of truth for mode-aware rendering throughout
/// the app. All nav, dashboards, and coaching context should watch this.
final appModeProvider = Provider<AppMode>((ref) {
  final metrics = ref.watch(userMetricsProvider).value;
  return (metrics?.isPregnant ?? false) ? AppMode.pregnancy : AppMode.cycle;
});
