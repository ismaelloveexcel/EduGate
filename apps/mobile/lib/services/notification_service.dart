import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/models/child_model.dart';

/// Top-level handler for background/terminated FCM messages.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No-op: background messages are handled when tapped via
  // FirebaseMessaging.onMessageOpenedApp or getInitialMessage.
}

/// Android notification channel for foreground heads-up banners.
const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
  'edugate_quiz_channel',
  'Quiz Notifications',
  description: 'Notifications for quiz reminders and results',
  importance: Importance.high,
);

/// Riverpod provider for the single NotificationService instance.
/// The default [Provider] caches the instance for the lifetime of the
/// [ProviderScope], so only one instance (and one set of listeners) exists.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(service.dispose);
  return service;
});

/// Firestore collection name for parent documents.
const _kParentsCollection = 'parents';

/// Single entry-point service that manages:
/// - Push permission requests (iOS + Android 13+)
/// - FCM token registration and refresh
/// - Token storage in Firestore under `parents/{parentId}`
/// - Foreground notification display via flutter_local_notifications
/// - Deep-link routing from notification tap → correct child quiz
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  GoRouter? _router;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundMsgSub;
  StreamSubscription<RemoteMessage>? _backgroundTapSub;

  String? _lastKnownToken;

  /// Initialise the service. Call once after [Firebase.initializeApp].
  ///
  /// [router] is used to navigate when a notification is tapped.
  Future<void> init({required GoRouter router}) async {
    _router = router;

    // Register the background handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permissions (iOS always, Android 13+).
    await _requestPermission();

    // Set up the Android notification channel.
    await _createAndroidChannel();

    // Initialise flutter_local_notifications.
    await _initLocalNotifications();

    // Listen for foreground messages → show local notification.
    _foregroundMsgSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Handle notification tap while app is in background.
    _backgroundTapSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_onMessageTapped);

    // Handle notification tap that launched the app from terminated state.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onMessageTapped(initialMessage);
    }
  }

  // -------------------------------------------------------
  // Permission
  // -------------------------------------------------------

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
      'FCM permission status: ${settings.authorizationStatus}',
    );
  }

  // -------------------------------------------------------
  // FCM token
  // -------------------------------------------------------

  /// Get the current FCM token and store it. Also listen for refreshes.
  /// Safe to call multiple times — the refresh listener is replaced, not duplicated.
  Future<void> registerToken({required String parentId}) async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _storeToken(parentId: parentId, token: token);
    }

    // Cancel any previous listener before creating a new one.
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((newToken) {
      _storeToken(parentId: parentId, token: newToken);
    });

    _lastKnownToken = token;
  }

  Future<void> _storeToken({
    required String parentId,
    required String token,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection(_kParentsCollection)
        .doc(parentId);

    await docRef.set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));

    if (_lastKnownToken != null && _lastKnownToken != token) {
      await docRef.update({
        'fcmTokens': FieldValue.arrayRemove([_lastKnownToken!]),
      });
    }

    _lastKnownToken = token;
    debugPrint('FCM token stored for parent $parentId');
  }

  // -------------------------------------------------------
  // Local notifications setup
  // -------------------------------------------------------

  Future<void> _createAndroidChannel() async {
    // Only needed on Android.
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_androidChannel);
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false, // already handled by FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );
  }

  // -------------------------------------------------------
  // Foreground message → show banner
  // -------------------------------------------------------

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      // Pass the deep-link path in payload so tapping routes correctly.
      payload: message.data['route'] as String?,
    );
  }

  // -------------------------------------------------------
  // Notification tap → deep-link
  // -------------------------------------------------------

  void _onMessageTapped(RemoteMessage message) {
    final route = message.data['route'] as String?;
    if (route != null && _router != null) {
      _router!.go(route);
    }
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    final route = response.payload;
    if (route != null && route.isNotEmpty && _router != null) {
      _router!.go(route);
    }
  }

  // -------------------------------------------------------
  // Quiz reminder scheduling
  // -------------------------------------------------------

  /// Schedules a local quiz reminder for [child] after their configured interval.
  /// Respects quiet hours by adjusting the trigger time forward if needed.
  Future<void> scheduleNextQuiz(ChildModel child) async {
    var triggerTime = DateTime.now().add(
      Duration(minutes: child.quizIntervalMinutes),
    );

    triggerTime = _adjustForQuietHours(
      triggerTime,
      child.quietHoursStart,
      child.quietHoursEnd,
    );

    final delay = triggerTime.difference(DateTime.now());
    if (delay.isNegative) return;

    // Use a unique ID per child so re-scheduling replaces the previous one
    final notificationId = child.id.hashCode.abs() % 100000;

    Future.delayed(delay, () {
      _localNotifications.show(
        notificationId,
        'Quiz Time! 🧠',
        '${child.name}, ready for a quick quiz?',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: '/quiz/${child.id}',
      );
    });
  }

  /// Cancels any pending quiz notification for [childId].
  Future<void> cancelQuizReminder(String childId) async {
    final notificationId = childId.hashCode.abs() % 100000;
    await _localNotifications.cancel(notificationId);
  }

  DateTime _adjustForQuietHours(DateTime time, int quietStart, int quietEnd) {
    final hour = time.hour;

    // Handle quiet hours that span midnight (e.g., 22:00 - 07:00)
    if (quietStart > quietEnd) {
      if (hour >= quietStart || hour < quietEnd) {
        if (hour >= quietStart) {
          return DateTime(time.year, time.month, time.day + 1, quietEnd);
        } else {
          return DateTime(time.year, time.month, time.day, quietEnd);
        }
      }
    } else if (quietStart < quietEnd) {
      // Quiet hours within same day (e.g., 13:00 - 15:00)
      if (hour >= quietStart && hour < quietEnd) {
        return DateTime(time.year, time.month, time.day, quietEnd);
      }
    }

    return time;
  }

  /// Cancel all stream subscriptions. Called automatically by the
  /// Riverpod provider's [onDispose] callback.
  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundMsgSub?.cancel();
    _backgroundTapSub?.cancel();
  }
}
