import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:routine/db/entities/birthday.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return; // Web support requires different setup

    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        // Handle notification tap
      },
    );
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timeZoneInfo.identifier;
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // If failed to get location, fallback to UTC or handle error
      debugPrint('Could not get local timezone: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;

    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleBirthdayNotification(Birthday birthday) async {
    if (kIsWeb) return;

    // Use hash of ID for notification ID, ensuring it fits within int range
    final int notificationId = birthday.id.hashCode;

    // Calculate next birthday instance
    // We want to schedule it for 9:00 AM
    final tz.TZDateTime nowTz = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      nowTz.year,
      birthday.date.month,
      birthday.date.day,
      9, // 9:00 AM
      0,
    );

    if (scheduledDate.isBefore(nowTz)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        nowTz.year + 1,
        birthday.date.month,
        birthday.date.day,
        9,
        0,
      );
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Birthday Reminder 🎂',
      "It's ${birthday.name}'s birthday today!",
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'birthdays_channel',
          'Birthdays',
          channelDescription: 'Reminders for birthdays',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // Note: uiLocalNotificationDateInterpretation has been removed in newer versions
      // The plugin now handles date interpretation automatically
      // For yearly recurrence, we schedule the next occurrence
      // When the app is opened, we can re-sync and schedule the following year
    );
  }

  Future<void> cancelNotification(String birthdayId) async {
    await flutterLocalNotificationsPlugin.cancel(birthdayId.hashCode);
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
