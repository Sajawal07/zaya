import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';

enum StepSource { none, deviceSensor, healthConnect }

class DeviceStepService {
  static StreamSubscription<StepCount>? _subscription;
  static int _todaySteps = 0;

  /// Stream of step count updates from the device sensor.
  static Stream<int> get stepStream {
    return Pedometer.stepCountStream.map((event) {
      _todaySteps = event.steps;
      return _todaySteps;
    });
  }

  /// Check if the step counter sensor is available on this device.
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

      // Timeout after 2 seconds — if no event, sensor likely unavailable
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

  /// Request ACTIVITY_RECOGNITION permission (Android 10+).
  static Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  /// Check if permission is already granted.
  static Future<bool> hasPermission() async {
    final status = await Permission.activityRecognition.status;
    return status.isGranted;
  }

  /// Start listening to the step counter sensor.
  static void startListening() {
    _subscription?.cancel();
    _subscription = Pedometer.stepCountStream.listen(
      (event) {
        _todaySteps = event.steps;
      },
      onError: (_) {},
    );
  }

  /// Stop listening to the step counter sensor.
  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Get the current step count.
  static int get currentSteps => _todaySteps;
}
