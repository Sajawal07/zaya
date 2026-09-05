import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';

enum StepSource { none, deviceSensor, healthConnect }

class _StepState {
  int baselineSteps = 0;
  int todaySteps = 0;
  String baselineDate = '';
}

class DeviceStepService {
  static final Map<String, _StepState> _stepStates = {};
  static final Map<String, StreamSubscription<StepCount>?> _subscriptions = {};

  static Future<void> init(String uid) async {
    final state = _stepStates[uid] ?? _StepState();
    final prefs = await SharedPreferences.getInstance();
    final today = _todayDateString();
    final savedDate = prefs.getString(_kStepBaselineDate(uid)) ?? '';

    if (savedDate == today) {
      state.baselineSteps = prefs.getInt(_kStepBaseline(uid)) ?? 0;
      state.baselineDate = today;
    } else {
      state.baselineSteps = 0;
      state.baselineDate = today;
    }
    _stepStates[uid] = state;
  }

  static Stream<int> get stepStream {
    return Pedometer.stepCountStream.asyncMap((event) async {
      await _handleRawSteps(event.steps);
      return currentSteps;
    });
  }

  static Future<void> _handleRawSteps(int rawSteps) async {
    final uid = _currentUid;
    if (uid == null) return;
    final state = _stepStates[uid] ?? _StepState();
    final today = _todayDateString();

    if (state.baselineDate != today) {
      state.baselineDate = today;
      state.baselineSteps = rawSteps;
      state.todaySteps = 0;
      await _saveBaseline(uid, rawSteps, today);
    } else if (state.baselineSteps == 0 && rawSteps > 0) {
      final prefs = await SharedPreferences.getInstance();
      final savedBaseline = prefs.getInt(_kStepBaseline(uid)) ?? 0;
      if (savedBaseline == 0) {
        state.baselineSteps = rawSteps;
        await _saveBaseline(uid, rawSteps, today);
      } else {
        state.baselineSteps = savedBaseline;
      }
      state.todaySteps = (rawSteps - state.baselineSteps).clamp(0, 999999);
    } else {
      state.todaySteps = (rawSteps - state.baselineSteps).clamp(0, 999999);
    }
    _stepStates[uid] = state;
  }

  static Future<void> _saveBaseline(String uid, int baseline, String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kStepBaseline(uid), baseline);
    await prefs.setString(_kStepBaselineDate(uid), date);
  }

  static String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String? _currentUid;

  static Future<bool> isSensorAvailable() async {
    try {
      final stream = Pedometer.stepCountStream;
      final completer = Completer<bool>();

      final sub = stream.listen(
        (_) {
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (_) {
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!completer.isCompleted) {
          completer.complete(false);
          sub.cancel();
        }
      });

      return completer.future;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  static Future<bool> hasPermission() async {
    final status = await Permission.activityRecognition.status;
    return status.isGranted;
  }

  static void startListening(String uid) {
    _currentUid = uid;
    stopListening();
    _subscriptions[uid] = Pedometer.stepCountStream.listen(
      (event) async {
        await _handleRawSteps(event.steps);
      },
      onError: (_) {},
    );
  }

  static void stopListening() {
    for (final sub in _subscriptions.values) {
      sub?.cancel();
    }
    _subscriptions.clear();
    _currentUid = null;
  }

  static Future<void> reset(String uid) async {
    _stepStates.remove(uid);
    _subscriptions[uid]?.cancel();
    _subscriptions.remove(uid);
    _currentUid = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_kStepBaseline(uid));
    prefs.remove(_kStepBaselineDate(uid));
  }

  static int get currentSteps {
    final uid = _currentUid;
    if (uid == null) return 0;
    return _stepStates[uid]?.todaySteps ?? 0;
  }

  static String _kStepBaseline(String uid) => 'step_baseline_count_$uid';
  static String _kStepBaselineDate(String uid) => 'step_baseline_date_$uid';
}