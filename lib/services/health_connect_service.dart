import 'dart:io';
import 'package:health/health.dart';

class HealthConnectData {
  final int? steps;
  final int? workoutMinutes;
  final double? sleepHours;

  HealthConnectData({this.steps, this.workoutMinutes, this.sleepHours});
}

class HealthConnectService {
  static final Health _health = Health();
  static bool _configured = false;

  static final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.WORKOUT,
    HealthDataType.SLEEP_SESSION,
  ];

  static bool get isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  static Future<void> _ensureConfigured() async {
    if (!_configured) {
      await _health.configure();
      _configured = true;
    }
  }

  static Future<bool> isAvailable() async {
    if (!isSupportedPlatform) return false;
    try {
      await _ensureConfigured();
      if (Platform.isAndroid) {
        return await _health.isHealthConnectAvailable();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Install Health Connect if not available (Android only).
  static Future<void> promptInstall() async {
    if (!isSupportedPlatform || !Platform.isAndroid) return;
    try {
      await _ensureConfigured();
      await _health.installHealthConnect();
    } catch (_) {}
  }

  static Future<bool> hasPermission() async {
    if (!isSupportedPlatform) return false;
    try {
      await _ensureConfigured();
      final result = await _health.hasPermissions(_types);
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestPermissions() async {
    if (!isSupportedPlatform) return false;

    try {
      await _ensureConfigured();

      if (Platform.isAndroid) {
        final status = await _health.getHealthConnectSdkStatus();
        if (status != HealthConnectSdkStatus.sdkAvailable) {
          return false;
        }
      }

      final authorized = await _health.requestAuthorization(
        _types,
        permissions: [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ],
      );
      return authorized;
    } catch (_) {
      return false;
    }
  }

  static Future<HealthConnectData?> fetchTodayData() async {
    if (!isSupportedPlatform) return null;

    try {
      await _ensureConfigured();
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      int? steps;
      int? workoutMinutes;
      double? sleepHours;

      // Fetch steps using the dedicated aggregate method
      try {
        final totalSteps = await _health.getTotalStepsInInterval(midnight, now);
        if (totalSteps != null && totalSteps > 0) {
          steps = totalSteps;
        }
      } catch (_) {}

      // Fetch workout data — compute duration from dateFrom/dateTo
      try {
        final workoutData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.WORKOUT],
          startTime: midnight,
          endTime: now,
        );
        if (workoutData.isNotEmpty) {
          int totalMinutes = 0;
          for (final point in workoutData) {
            totalMinutes += point.dateTo.difference(point.dateFrom).inMinutes;
          }
          if (totalMinutes > 0) workoutMinutes = totalMinutes;
        }
      } catch (_) {}

      // Fetch sleep data
      try {
        final sleepData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_SESSION],
          startTime: midnight,
          endTime: now,
        );
        if (sleepData.isNotEmpty) {
          double totalHours = 0;
          for (final point in sleepData) {
            totalHours += point.dateTo.difference(point.dateFrom).inMinutes / 60.0;
          }
          if (totalHours > 0) sleepHours = totalHours;
        }
      } catch (_) {}

      return HealthConnectData(
        steps: steps,
        workoutMinutes: workoutMinutes,
        sleepHours: sleepHours,
      );
    } catch (_) {
      return null;
    }
  }
}
