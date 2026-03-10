import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:zaya/core/app_colors.dart';
import '../models/notification.dart';
import 'database_service.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // default icon
      [
        NotificationChannel(
          channelGroupKey: 'cycle_group',
          channelKey: 'cycle_alerts',
          channelName: 'Cycle Reminders',
          channelDescription: 'Notifications for period tracking, ovulation, and cycle alerts',
          defaultColor: const Color(0xFFD47A8E),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
        ),
        NotificationChannel(
          channelGroupKey: 'pregnancy_group',
          channelKey: 'appointments',
          channelName: 'Pregnancy Appointments',
          channelDescription: 'Reminders for your prenatal checkups and scans',
          defaultColor: AppColors.pregnancyGold,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          criticalAlerts: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'cycle_group',
          channelGroupName: 'Cycle Tracking',
        ),
        NotificationChannelGroup(
          channelGroupKey: 'pregnancy_group',
          channelGroupName: 'Pregnancy journey',
        ),
      ],
      debug: true,
    );

    // Initialize FCM
    await _initFCM();

    // Request permissions proactively
    await checkAndRequestPermissions();
  }

  static Future<void> _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for iOS
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: message.hashCode,
            channelKey: 'cycle_alerts',
            title: message.notification?.title,
            body: message.notification?.body,
            notificationLayout: NotificationLayout.Default,
          ),
        );
      }
    });
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background FCM
    debugPrint("Handling a background message: ${message.messageId}");
  }

  static Future<String?> getFCMToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  static Future<void> checkAndRequestPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications(
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light,
          NotificationPermission.PreciseAlarms,
        ],
      );
    }
  }

  // Schedule a complete sequence of cycle reminders locally (Spark Plan Solution)
  static Future<void> scheduleCycleSequence(DateTime lastPeriodDate) async {
    // 1. Cancel any existing reminders first
    await cancelCycleNotifications();
    
    final now = DateTime.now();

    // 2. Ovulation Reminder (Day 12)
    final ovulationDay = lastPeriodDate.add(const Duration(days: 11));
    if (ovulationDay.isAfter(now)) {
      await _createScheduled(
        id: 101,
        title: 'Ovulation Day! 🌸',
        body: 'Today is your ovulation day. Best time to try to conceive!',
        date: ovulationDay,
      );
    }

    // 3. Period Expected (Day 29)
    final periodDueDay = lastPeriodDate.add(const Duration(days: 28));
    if (periodDueDay.isAfter(now)) {
      await _createScheduled(
        id: 102,
        title: 'Period Expected Soon 🔔',
        body: 'It looks like your period may have started. Please log it for accurate tracking.',
        date: periodDueDay,
      );
    }

    // 4. Daily Missed Period Follow-ups (Days 30-35)
    for (int i = 1; i <= 6; i++) {
      final followUpDay = periodDueDay.add(Duration(days: i));
      if (followUpDay.isAfter(now)) {
        await _createScheduled(
          id: 110 + i,
          title: 'Cycle Pending... 📅',
          body: 'Your cycle is pending. Please monitor or log your period in the app.',
          date: followUpDay,
        );
      }
    }

    // 5. Late Period Alert (Day 36)
    final lateAlertDay = lastPeriodDate.add(const Duration(days: 35));
    if (lateAlertDay.isAfter(now)) {
      await _createScheduled(
        id: 103,
        title: 'Period Significantly Late ⚠️',
        body: 'Your period is significantly delayed. If not trying to conceive, consult a doctor.',
        date: lateAlertDay,
      );
    }
  }

  static Future<void> _createScheduled({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'cycle_alerts',
          title: title,
          body: body,
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
        ),
        schedule: NotificationCalendar.fromDate(
          date: date,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );

      // Save to local DB for in-app notification center
      try {
        final db = DatabaseService();
        final notification = AppNotification()
          ..title = title
          ..body = body
          ..timestamp = date
          ..category = 'cycle';
        await db.saveNotification(notification);
      } catch (e) {
        debugPrint('Error saving notification context: $e');
      }
    } catch (e) {
      debugPrint('Error scheduling local notification: $e');
    }
  }

  static Future<void> cancelCycleNotifications() async {
    // Cancel specific IDs
    await AwesomeNotifications().cancel(101); // Ovulation
    await AwesomeNotifications().cancel(102); // Period Due
    await AwesomeNotifications().cancel(103); // Late Alert
    for (int i = 1; i <= 6; i++) {
      await AwesomeNotifications().cancel(110 + i); // Follow-ups
    }
  }

  static Future<void> scheduleAppointmentReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final reminderTime = scheduledDate.subtract(const Duration(hours: 2));
    if (reminderTime.isBefore(DateTime.now())) return;

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'appointments',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          fullScreenIntent: true,
        ),
        schedule: NotificationCalendar.fromDate(
          date: reminderTime,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}
