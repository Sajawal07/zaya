import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_metrics.dart';
import 'database_provider.dart';
import 'metrics_provider.dart';
import '../features/health/domain/services/pcos_analyzer.dart';

class PcosState {
  final UserMetrics metrics;
  final PcosAnalysis? analysis;
  final bool isLoading;

  PcosState({
    required this.metrics,
    this.analysis,
    this.isLoading = false,
  });

  PcosState copyWith({
    UserMetrics? metrics,
    PcosAnalysis? analysis,
    bool? isLoading,
  }) {
    return PcosState(
      metrics: metrics ?? this.metrics,
      analysis: analysis ?? this.analysis,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PcosNotifier extends StateNotifier<AsyncValue<PcosState>> {
  final Ref ref;

  PcosNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = AsyncValue.error("User not logged in", StackTrace.current);
      return;
    }

    final db = ref.read(databaseServiceProvider);
    final metrics = await db.getUserMetrics(user.uid) ?? UserMetrics()..userId = user.uid;
    
    final analysis = PcosAnalyzer.analyze(
      bmi: metrics.bmi,
      irregularPeriods: metrics.irregularPeriods,
      sugarCravings: metrics.sugarCravings,
      acne: metrics.acne,
      hairFall: metrics.hairFall,
      facialHair: metrics.facialHair,
      fatigue: metrics.fatigue,
      brainFog: metrics.brainFog,
      anxiety: metrics.anxiety,
      sleepIssues: metrics.sleepIssues,
      recentlyStoppedPill: metrics.recentlyStoppedPill,
      dheaLevel: 0, // Default for now
    );

    state = AsyncValue.data(PcosState(metrics: metrics, analysis: analysis));
  }

  Future<void> updateSymptom(String symptom, bool value) async {
    if (!state.hasValue) return;
    
    final current = state.value!;
    final updatedMetrics = current.metrics;

    switch (symptom) {
      case 'irregularPeriods': updatedMetrics.irregularPeriods = value; break;
      case 'sugarCravings': updatedMetrics.sugarCravings = value; break;
      case 'acne': updatedMetrics.acne = value; break;
      case 'hairFall': updatedMetrics.hairFall = value; break;
      case 'facialHair': updatedMetrics.facialHair = value; break;
      case 'fatigue': updatedMetrics.fatigue = value; break;
      case 'brainFog': updatedMetrics.brainFog = value; break;
      case 'anxiety': updatedMetrics.anxiety = value; break;
      case 'sleepIssues': updatedMetrics.sleepIssues = value; break;
      case 'recentlyStoppedPill': updatedMetrics.recentlyStoppedPill = value; break;
    }

    final analysis = PcosAnalyzer.analyze(
      bmi: updatedMetrics.bmi,
      irregularPeriods: updatedMetrics.irregularPeriods,
      sugarCravings: updatedMetrics.sugarCravings,
      acne: updatedMetrics.acne,
      hairFall: updatedMetrics.hairFall,
      facialHair: updatedMetrics.facialHair,
      fatigue: updatedMetrics.fatigue,
      brainFog: updatedMetrics.brainFog,
      anxiety: updatedMetrics.anxiety,
      sleepIssues: updatedMetrics.sleepIssues,
      recentlyStoppedPill: updatedMetrics.recentlyStoppedPill,
      dheaLevel: 0,
    );

    state = AsyncValue.data(current.copyWith(metrics: updatedMetrics, analysis: analysis));
  }

  Future<void> save() async {
    if (!state.hasValue) return;
    final db = ref.read(databaseServiceProvider);
    await db.saveUserMetrics(state.value!.metrics);
    ref.invalidate(userMetricsProvider);
  }
}

final pcosProvider = StateNotifierProvider<PcosNotifier, AsyncValue<PcosState>>((ref) {
  return PcosNotifier(ref);
});
