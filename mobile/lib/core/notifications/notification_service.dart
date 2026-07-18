import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/habits/domain/entities/habit.dart';
import '../../features/habits/domain/entities/habit_reminder.dart';

const _weekdayCodes = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

/// Schedules and cancels local notifications for habit reminders.
///
/// One notification id is derived deterministically from `(reminderId,
/// weekday)` — see [_notificationId] — so rescheduling never needs a stored
/// id lookup table; `weekday == 0` is the "every day" sentinel for a
/// reminder with an empty `daysOfWeek`.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Set when a reminder notification is tapped — foreground, background, or
  /// as the cold-start launch payload. `ForgeApp` listens to this to deep
  /// link into the habit once the router exists (see app_router.dart).
  final ValueNotifier<String?> pendingHabitId = ValueNotifier(null);

  static const _channelId = 'habit_reminders';

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    // DateTime.now().timeZoneName gives a non-IANA abbreviation ("IST",
    // "PST") that tz.getLocation can't resolve — silently falling back to
    // UTC there previously meant every reminder fired 5-6 hours off from the
    // intended wall-clock time. flutter_timezone returns the real IANA name
    // (e.g. "Asia/Kolkata").
    try {
      tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));
    } catch (_) {
      // Still fall back rather than crash startup if a device reports
      // something tz.getLocation truly can't resolve.
    }

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) pendingHabitId.value = response.payload;
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          'Habit reminders',
          description: "Reminders for habits you've scheduled",
          importance: Importance.high,
        ));

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails?.notificationResponse?.payload;
      if (payload != null) pendingHabitId.value = payload;
    }
  }

  /// Requests notification permission (and, on Android 12+, exact-alarm
  /// scheduling). Call this the first time a user adds a reminder, not at
  /// app launch — asking before there's a reason reads as spammy.
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestExactAlarmsPermission();
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
  }

  Future<void> scheduleReminder(Habit habit, HabitReminder reminder) async {
    await cancelReminder(reminder.id);
    if (!reminder.active) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Habit reminders',
        channelDescription: "Reminders for habits you've scheduled",
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final weekdays = reminder.daysOfWeek.isEmpty
        ? const [0]
        : reminder.daysOfWeek.map((code) => _weekdayCodes.indexOf(code) + 1).where((w) => w > 0).toList();

    for (final weekday in weekdays) {
      await _plugin.zonedSchedule(
        _notificationId(reminder.id, weekday),
        habit.name,
        'Time to ${habit.name}',
        _nextInstance(reminder.hour, reminder.minute, weekday),
        details,
        payload: habit.id,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: weekday == 0 ? DateTimeComponents.time : DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelReminder(String reminderId) async {
    for (var weekday = 0; weekday <= 7; weekday++) {
      await _plugin.cancel(_notificationId(reminderId, weekday));
    }
  }

  Future<void> cancelAllForReminders(Iterable<String> reminderIds) async {
    for (final id in reminderIds) {
      await cancelReminder(id);
    }
  }

  tz.TZDateTime _nextInstance(int hour, int minute, int weekday) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (weekday == 0) {
      while (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      return scheduled;
    }
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  int _notificationId(String reminderId, int weekday) {
    return (reminderId.hashCode ^ (weekday * 0x9E3779B1)) & 0x7fffffff;
  }
}
