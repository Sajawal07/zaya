import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hercycle_bloom/firebase_options.dart';
import 'package:hercycle_bloom/core/app_colors.dart';
import 'package:hercycle_bloom/core/cycle_math.dart';
import 'package:hercycle_bloom/core/navigator_key.dart';
import 'package:hercycle_bloom/features/pregnancy/presentation/screens/appointments_screen.dart';
import 'package:hercycle_bloom/features/pregnancy/presentation/screens/pregnancy_home_screen.dart';
import 'package:hercycle_bloom/features/home/presentation/screens/notification_screen.dart';
import '../models/notification.dart';
import 'database_service.dart';

class NotificationService {
  static const int _idFertileStart = 100;
  static const int _idFertilePeak = 101;
  static const int _idOvulation = 102;
  static const int _idPeriodSoon = 103;
  static const int _idPeriodDue = 104;
  static const int _idPeriodLate1 = 105;
  static const int _idPeriodLate3 = 106;
  static const int _idPeriodLate7 = 107;

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
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
        NotificationChannel(
          channelGroupKey: 'pregnancy_group',
          channelKey: 'pregnancy_weekly',
          channelName: 'Weekly Pregnancy Updates',
          channelDescription: 'Weekly milestone and development notifications',
          defaultColor: AppColors.pregnancyGold,
          ledColor: Colors.white,
          importance: NotificationImportance.Default,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelGroupKey: 'pregnancy_group',
          channelKey: 'pregnancy_health',
          channelName: 'Pregnancy Health Reminders',
          channelDescription: 'Daily hydration, nutrition, and movement reminders',
          defaultColor: const Color(0xFF4A9373),
          ledColor: Colors.white,
          importance: NotificationImportance.Low,
          channelShowBadge: false,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'cycle_group',
          channelGroupName: 'Cycle Tracking',
        ),
        NotificationChannelGroup(
          channelGroupKey: 'pregnancy_group',
          channelGroupName: 'Pregnancy Journey',
        ),
      ],
      debug: true,
    );

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceived,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
    );

    await _initFCM();
    await checkAndRequestPermissions();
  }

  /// Saves to in-app inbox only when a notification actually fires (not when scheduled).
  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayed(ReceivedNotification received) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      final title = received.title;
      final body = received.body;
      if (title == null) return;

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final db = DatabaseService(uid);
      await db.saveNotification(
        AppNotification()
          ..title = title
          ..body = body ?? ''
          ..timestamp = DateTime.now()
          ..category = received.channelKey == 'cycle_alerts' ? 'cycle' : 'app',
      );
    } catch (e) {
      debugPrint('Error saving displayed notification: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceived(ReceivedAction action) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final id = action.id;
      final channelKey = action.channelKey;
      debugPrint('Notification action received: id=$id, channelKey=$channelKey');

      final context = navigatorKey.currentContext;
      if (context != null) {
        if (channelKey == 'appointments') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
          );
        } else if (channelKey == 'pregnancy_weekly' ||
            channelKey == 'pregnancy_health' ||
            (id != null && id >= 200 && id <= 299)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PregnancyHomeScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('Error handling notification action: $e');
    }
  }

  static Future<void> _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
    try {
      WidgetsFlutterBinding.ensureInitialized();
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      debugPrint('Handling a background message: ${message.messageId}');

      if (message.notification != null || message.data.isNotEmpty) {
        final title = message.notification?.title ?? message.data['title'];
        final body = message.notification?.body ?? message.data['body'];

        if (title != null) {
          await AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: message.hashCode,
              channelKey: 'cycle_alerts',
              title: title,
              body: body,
              payload: Map<String, String>.from(message.data),
              notificationLayout: NotificationLayout.Default,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in FCM background handler: $e');
    }
  }

  static Future<String?> getFCMToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  static Future<void> checkAndRequestPermissions() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
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


  /// Loads avg cycle from DB (or 28) then schedules reminders.
  static Future<void> scheduleCycleSequence(DateTime lastPeriodDate, {int? cycleLength}) async {
    var length = cycleLength ?? CycleMath.defaultLength;
    if (cycleLength == null) {
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final db = DatabaseService(uid);
          final starts = await db.getAllPeriodStarts(uid);
          length = CycleMath.averageFromLogs(starts);
        }
      } catch (e) {
        debugPrint('Avg cycle lookup failed, using $length: $e');
      }
    }

    await cancelCycleNotifications();
    // Scrub old future "fake inbox" rows from previous buggy saves.
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await DatabaseService(uid).deleteFutureNotifications();
      }
    } catch (_) {}

    final start = CycleMath.dayOnly(lastPeriodDate);
    final ovulationDayNum = CycleMath.ovulationDay(length);
    final fertileStartNum = CycleMath.fertileStartDay(length);
    final now = DateTime.now();

    // Fertile window opens (try-to-conceive window starts)
    await _scheduleIfFuture(
      id: _idFertileStart,
      title: 'Fertile Window Opening',
      body:
          'Your fertile window starts today. Higher chance of conception over the next few days.',
      when: CycleMath.atMorning(start.add(Duration(days: fertileStartNum - 1))),
      now: now,
    );

    // Day before ovulation — peak fertility reminder
    await _scheduleIfFuture(
      id: _idFertilePeak,
      title: 'Peak Fertility Tomorrow',
      body:
          'Ovulation is expected tomorrow. If you are trying to conceive, today and tomorrow are key days.',
      when: CycleMath.atMorning(start.add(Duration(days: ovulationDayNum - 2))),
      now: now,
    );

    // Ovulation day — must-have
    await _scheduleIfFuture(
      id: _idOvulation,
      title: 'Ovulation Day',
      body:
          'Today is your predicted ovulation day — the best day to try to conceive.',
      when: CycleMath.atMorning(start.add(Duration(days: ovulationDayNum - 1))),
      now: now,
    );

    // Period approaching (2 days before)
    await _scheduleIfFuture(
      id: _idPeriodSoon,
      title: 'Period Coming Soon',
      body:
          'Your period is expected in about 2 days. Have supplies ready and log when it starts.',
      when: CycleMath.atMorning(start.add(Duration(days: length - 2))),
      now: now,
    );

    // Period due day
    await _scheduleIfFuture(
      id: _idPeriodDue,
      title: 'Period Expected Today',
      body:
          'Your period may start today based on your cycle average. Please log it for accurate tracking.',
      when: CycleMath.atMorning(start.add(Duration(days: length))),
      now: now,
    );

    // Late follow-ups
    await _scheduleIfFuture(
      id: _idPeriodLate1,
      title: 'Period 1 Day Late',
      body: 'Your period is 1 day late. Log it when it starts, or keep monitoring.',
      when: CycleMath.atMorning(start.add(Duration(days: length + 1))),
      now: now,
    );

    await _scheduleIfFuture(
      id: _idPeriodLate3,
      title: 'Period 3 Days Late',
      body:
          'Your period is 3 days late. Please log any spotting or start date in the app.',
      when: CycleMath.atMorning(start.add(Duration(days: length + 3))),
      now: now,
    );

    await _scheduleIfFuture(
      id: _idPeriodLate7,
      title: 'Period Significantly Late',
      body:
          'Your period is about a week late. If you are not trying to conceive, consider checking with a doctor.',
      when: CycleMath.atMorning(start.add(Duration(days: length + 7))),
      now: now,
    );

    debugPrint(
      'Scheduled cycle reminders from $start, avgLength=$length, '
      'ovulationDay=$ovulationDayNum, fertileStart=$fertileStartNum',
    );
  }

  static Future<void> _scheduleIfFuture({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    required DateTime now,
  }) async {
    if (!when.isAfter(now)) return;
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'cycle_alerts',
          title: title,
          body: body,
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
        ),
        schedule: NotificationCalendar.fromDate(
          date: when,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
      // Do NOT write to Isar here — inbox only gets items when they actually fire.
    } catch (e) {
      debugPrint('Error scheduling notification $id: $e');
    }
  }

  static Future<void> cancelCycleNotifications() async {
    for (final id in [
      _idFertileStart,
      _idFertilePeak,
      _idOvulation,
      _idPeriodSoon,
      _idPeriodDue,
      _idPeriodLate1,
      _idPeriodLate3,
      _idPeriodLate7,
    ]) {
      await AwesomeNotifications().cancel(id);
    }
    // Legacy IDs from older builds
    await AwesomeNotifications().cancel(110);
    await AwesomeNotifications().cancel(111);
    await AwesomeNotifications().cancel(112);
    await AwesomeNotifications().cancel(113);
    await AwesomeNotifications().cancel(114);
    await AwesomeNotifications().cancel(115);
    await AwesomeNotifications().cancel(116);
  }

  // ── Pregnancy Notifications ────────────────────────────────────────────────

  static Future<void> schedulePregnancySequence(DateTime lmpDate) async {
    await cancelPregnancyNotifications();
    final now = DateTime.now();

    const weekMessages = {
      8: ('Week 8 Update', 'Baby is developing fingers and toes. Nausea may peak — eat small, frequent meals.'),
      12: ('Week 12 Milestone', 'End of 1st trimester! Risk of miscarriage drops significantly.'),
      16: ('Week 16 Update', 'Baby can now make facial expressions. Your energy may start returning.'),
      20: ('Halfway There!', 'You are 20 weeks pregnant. The anatomy scan window is open.'),
      24: ('Week 24 Milestone', 'Viability milestone reached! Baby has a strong chance of survival if born now.'),
      28: ('3rd Trimester Begins', 'Welcome to your third trimester! Baby can now open and close eyes.'),
      32: ('Week 32 Update', "Baby is storing fat for warmth. Start finalising your birth plan and hospital bag."),
      36: ('Almost There!', 'Weekly check-ups begin now. Baby\'s position is likely head-down.'),
      40: ('Due Date Week!', 'You have reached your due date week. Every day is a blessing — baby will arrive soon!'),
    };

    var id = 200;
    for (final entry in weekMessages.entries) {
      final notifDate = CycleMath.atMorning(lmpDate.add(Duration(days: entry.key * 7)));
      if (notifDate.isAfter(now)) {
        await _createScheduledOnChannel(
          id: id++,
          channelKey: 'pregnancy_weekly',
          title: entry.value.$1,
          body: entry.value.$2,
          date: notifDate,
        );
      }
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 299,
        channelKey: 'pregnancy_health',
        title: 'Good morning, mama',
        body: 'Remember: water, prenatal vitamins, and a short walk today.',
        category: NotificationCategory.Reminder,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        hour: 9,
        minute: 0,
        second: 0,
        repeats: true,
        allowWhileIdle: true,
      ),
    );
  }

  static Future<void> cancelPregnancyNotifications() async {
    for (var id = 200; id <= 299; id++) {
      await AwesomeNotifications().cancel(id);
    }
  }

  static Future<void> onModeSwitchToPregnancy(DateTime lmpDate) async {
    await cancelCycleNotifications();
    await schedulePregnancySequence(lmpDate);
  }

  static Future<void> onModeSwitchToCycle(DateTime? lastPeriodDate) async {
    await cancelPregnancyNotifications();
    if (lastPeriodDate != null) {
      await scheduleCycleSequence(lastPeriodDate);
    }
  }

  static Future<void> _createScheduledOnChannel({
    required int id,
    required String channelKey,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channelKey,
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
      // Inbox only when displayed — see _onNotificationDisplayed.
    } catch (e) {
      debugPrint('Error scheduling pregnancy notification: $e');
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
