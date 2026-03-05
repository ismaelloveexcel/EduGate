import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  }

  Future<void> _storeToken({
    required String parentId,
    required String token,
  }) async {
    await FirebaseFirestore.instance
        .collection(_kParentsCollection)
        .doc(parentId)
        .set({
          'fcmTokens': FieldValue.arrayUnion([token]),
        }, SetOptions(merge: true));
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

  /// Cancel all stream subscriptions. Called automatically by the
  /// Riverpod provider's [onDispose] callback.
  void dispose() {
    _tokenRefreshSub?.cancel();
    _foregroundMsgSub?.cancel();
    _backgroundTapSub?.cancel();
  }
}
