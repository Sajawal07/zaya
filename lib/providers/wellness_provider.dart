import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import 'auth_provider.dart';
import '../models/wellness.dart';

class WellnessState {
  final WellnessLog? todayLog;
  final List<WellnessLog> history;
  final bool isLoading;

  WellnessState({
    this.todayLog,
    this.history = const [],
    this.isLoading = false,
  });

  WellnessState copyWith({
    WellnessLog? todayLog,
    List<WellnessLog>? history,
    bool? isLoading,
  }) {
    return WellnessState(
      todayLog: todayLog ?? this.todayLog,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WellnessNotifier extends StateNotifier<WellnessState> {
  final Ref ref;
  final String? userId;

  WellnessNotifier(this.ref, this.userId) : super(WellnessState(isLoading: true)) {
    if (userId != null) {
      _init();
    } else {
      state = WellnessState();
    }
  }

  Future<void> _init() async {
    final db = ref.read(databaseServiceProvider);
    final today = await db.getWellnessLogForDate(userId!, DateTime.now());
    final history = await db.getWellnessLogs(userId!);
    state = WellnessState(todayLog: today, history: history, isLoading: false);
  }

  Future<void> logWellness({
    int? cramps,
    bool? bloating,
    int? moodSwings,
    int? dietScore,
    int? water,
    int? steps,
    int? workout,
    int? stress,
    double? sleepHours,
    int? sleepQuality,
    String? flow,
    double? weight,
    bool? acne,
    bool? hairThinning,
    bool? facialHair,
  }) async {
    if (userId == null) return;
    final db = ref.read(databaseServiceProvider);
    
    var log = state.todayLog ?? (WellnessLog()
      ..userId = userId!
      ..date = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
      ..createdAt = DateTime.now());

    if (cramps != null) log.crampsLevel = cramps;
    if (bloating != null) log.bloating = bloating;
    if (moodSwings != null) log.moodSwingLevel = moodSwings;
    if (dietScore != null) log.dietScore = dietScore;
    if (water != null) log.waterIntake = water;
    if (steps != null) log.steps = steps;
    if (workout != null) log.workoutMinutes = workout;
    if (stress != null) log.stressLevel = stress;
    if (sleepHours != null) log.sleepHours = sleepHours;
    if (sleepQuality != null) log.sleepQuality = sleepQuality;
    if (flow != null) log.flowIntensity = flow;
    if (weight != null) log.weight = weight;
    if (acne != null) log.acne = acne;
    if (hairThinning != null) log.hairThinning = hairThinning;
    if (facialHair != null) log.facialHair = facialHair;

    await db.saveWellnessLog(log);
    _init(); // Refresh
  }
}

final wellnessProvider = StateNotifierProvider<WellnessNotifier, WellnessState>((ref) {
  final user = ref.watch(currentUserProvider);
  return WellnessNotifier(ref, user?.uid);
});
