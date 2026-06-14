import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/entities/task.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    _initialized = true;
  }

  static int _notificationId(String taskId) =>
      taskId.hashCode.abs() % 2147483647;

  static Future<void> scheduleTaskReminder(Task task) async {
    if (!_initialized || task.dueDate == null || task.isCompleted) {
      await cancelTaskReminder(task.id);
      return;
    }

    final scheduledDate = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
      9,
    );

    if (scheduledDate.isBefore(DateTime.now())) {
      await cancelTaskReminder(task.id);
      return;
    }

    final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

    await _plugin.zonedSchedule(
      _notificationId(task.id),
      'Task due today',
      task.title,
      tzScheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_due_channel',
          'Task Due Reminders',
          channelDescription: 'Reminders for tasks that are due today',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelTaskReminder(String taskId) async {
    if (!_initialized) return;
    await _plugin.cancel(_notificationId(taskId));
  }

  static Future<void> syncAllReminders(List<Task> tasks) async {
    if (!_initialized) return;

    for (final task in tasks) {
      if (task.dueDate != null && !task.isCompleted) {
        await scheduleTaskReminder(task);
      } else {
        await cancelTaskReminder(task.id);
      }
    }
  }
}
