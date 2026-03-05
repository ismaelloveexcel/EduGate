// lib/shared/services/notification_service.dart
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'edugate_quiz';
  static const _channelName = 'Quiz Reminders';
  static const _channelDesc = 'Notifications to start micro-quizzes';

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navigation is handled in the router via a global key or navigator key.
    // The payload contains the childId to launch quiz for.
    // TODO: Wire up navigation via a stream / NavigatorKey.
  }

  /// Schedule a recurring quiz notification [intervalMinutes] from now.
  /// Respects quiet hours (quietStart..quietEnd in 24h format).
  Future<void> scheduleQuizNotification({
    required String childId,
    required String childName,
    required int intervalMinutes,
    required int quietHoursStart,
    required int quietHoursEnd,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = now.add(Duration(minutes: intervalMinutes));

    // Suppress notifications during quiet hours
    scheduledTime =
        _skipQuietHours(scheduledTime, quietHoursStart, quietHoursEnd);

    await _plugin.zonedSchedule(
      childId.hashCode.abs() % 100000,
      '⏰ Quiz Time, $childName!',
      'Tap to start your micro-quiz and earn XP!',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'quiz:$childId',
    );
  }

  tz.TZDateTime _skipQuietHours(
    tz.TZDateTime time,
    int quietStart,
    int quietEnd,
  ) {
    final hour = time.hour;
    final isQuiet = quietStart > quietEnd
        ? (hour >= quietStart || hour < quietEnd)
        : (hour >= quietStart && hour < quietEnd);

    if (!isQuiet) return time;

    // Move to end of quiet hours
    final endTime = tz.TZDateTime(
        tz.local, time.year, time.month, time.day, quietEnd, 0, 0);
    if (endTime.isAfter(time)) return endTime;
    return endTime.add(const Duration(days: 1));
  }

  Future<void> cancelNotification(String childId) async {
    await _plugin.cancel(childId.hashCode.abs() % 100000);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
