import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _local = FlutterLocalNotificationsPlugin();
const _androidChannel = AndroidNotificationChannel(
  'pengumuman_kampus',
  'Pengumuman Kampus',
  description: 'Notifikasi pengumuman kampus',
  importance: Importance.high,
);

class PushDebugState {
  const PushDebugState({
    this.permissionStatus = 'Belum diminta',
    this.currentTokenPreview,
    this.refreshCount = 0,
    this.lastSentTokenPreview,
    this.lastSentAt,
    this.errorMessage,
    this.topicSubscribed = false,
    this.topicOperationInProgress = false,
  });

  final String permissionStatus;
  final String? currentTokenPreview;
  final int refreshCount;
  final String? lastSentTokenPreview;
  final DateTime? lastSentAt;
  final String? errorMessage;
  final bool topicSubscribed;
  final bool topicOperationInProgress;

  PushDebugState copyWith({
    String? permissionStatus,
    String? currentTokenPreview,
    int? refreshCount,
    String? lastSentTokenPreview,
    DateTime? lastSentAt,
    String? errorMessage,
    bool? topicSubscribed,
    bool? topicOperationInProgress,
    bool clearError = false,
  }) {
    return PushDebugState(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      currentTokenPreview: currentTokenPreview ?? this.currentTokenPreview,
      refreshCount: refreshCount ?? this.refreshCount,
      lastSentTokenPreview: lastSentTokenPreview ?? this.lastSentTokenPreview,
      lastSentAt: lastSentAt ?? this.lastSentAt,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      topicSubscribed: topicSubscribed ?? this.topicSubscribed,
      topicOperationInProgress:
          topicOperationInProgress ?? this.topicOperationInProgress,
    );
  }
}

final pushDebugState = ValueNotifier(const PushDebugState());
final notificationEvents = ValueNotifier<List<NotificationEvent>>(const []);

String? pendingDeepLink;
StreamSubscription<String>? _tokenRefreshSubscription;
StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
void Function(String route)? _notificationRouteHandler;

class NotificationEvent {
  const NotificationEvent({
    required this.state,
    required this.route,
    required this.occurredAt,
  });

  final String state;
  final String route;
  final DateTime occurredAt;
}

String validatedNotificationRoute(Object? route) {
  if (route == '/') return '/';
  if (route is String && RegExp(r'^/pengumuman/\d+$').hasMatch(route)) {
    return route;
  }
  return '/';
}

void _recordNotificationEvent(String state, String route) {
  notificationEvents.value = [
    NotificationEvent(state: state, route: route, occurredAt: DateTime.now()),
    ...notificationEvents.value.take(9),
  ];
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Runs in a background isolate: do not access BuildContext, Riverpod, or the router.
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

String _tokenPreview(String token) {
  final prefixLength = token.length < 12 ? token.length : 12;
  return '${token.substring(0, prefixLength)}...';
}

void _recordCurrentToken(String token) {
  pushDebugState.value = pushDebugState.value.copyWith(
    currentTokenPreview: _tokenPreview(token),
    clearError: true,
  );
}

void recordPushError(Object error) {
  pushDebugState.value = pushDebugState.value.copyWith(
    errorMessage: 'Operasi FCM gagal (${error.runtimeType})',
  );
}

Future<bool> requestNotificationPermission() async {
  // Android 13+: this requests POST_NOTIFICATIONS. iOS: this requests alert,
  // badge, and sound authorization.
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  final status = switch (settings.authorizationStatus) {
    AuthorizationStatus.authorized => 'Diizinkan',
    AuthorizationStatus.provisional => 'Diizinkan sementara',
    AuthorizationStatus.denied => 'Ditolak',
    AuthorizationStatus.deniedPermanently => 'Ditolak permanen',
    AuthorizationStatus.notDetermined => 'Belum ditentukan',
  };
  pushDebugState.value = pushDebugState.value.copyWith(
    permissionStatus: status,
    clearError: true,
  );
  return settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional;
}

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _local.initialize(
    settings: const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: _handleLocalNotificationResponse,
  );
  await _local
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_androidChannel);

  final launchDetails = await _local.getNotificationAppLaunchDetails();
  if (launchDetails?.didNotificationLaunchApp ?? false) {
    pendingDeepLink = launchDetails?.notificationResponse?.payload;
  }
}

void _handleLocalNotificationResponse(NotificationResponse response) {
  final route = validatedNotificationRoute(response.payload);
  final routeHandler = _notificationRouteHandler;
  if (routeHandler == null) {
    pendingDeepLink = route;
  } else {
    routeHandler(route);
  }
}

void listenForeground(void Function(String route) go) {
  _notificationRouteHandler = go;
  _foregroundMessageSubscription ??= FirebaseMessaging.onMessage.listen(
    (message) {
      final route = validatedNotificationRoute(message.data['route']);
      _recordNotificationEvent('foreground', route);
      unawaited(_showForegroundNotification(message, route));
    },
    onError: (Object error) {
      recordPushError(error);
    },
  );
  _messageOpenedSubscription ??= FirebaseMessaging.onMessageOpenedApp.listen(
    (message) {
      final route = validatedNotificationRoute(message.data['route']);
      _recordNotificationEvent('background', route);
      go(route);
    },
    onError: (Object error) {
      recordPushError(error);
    },
  );
}

Future<void> handleTerminated(void Function(String route) go) async {
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  String? route;
  if (initial != null) {
    route = validatedNotificationRoute(initial.data['route']);
  } else if (pendingDeepLink != null) {
    route = validatedNotificationRoute(pendingDeepLink);
  }

  pendingDeepLink = null;
  if (route != null) {
    _recordNotificationEvent('terminated', route);
    go(route);
  }
}

Future<void> _showForegroundNotification(
  RemoteMessage message,
  String route,
) async {
  try {
    final notification = message.notification;
    await _local.show(
      id: message.hashCode,
      title: notification?.title ?? 'Pengumuman',
      body: notification?.body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: route,
    );
  } catch (error) {
    recordPushError(error);
  }
}

Future<void> setAnnouncementTopicSubscription(bool subscribed) async {
  pushDebugState.value = pushDebugState.value.copyWith(
    topicOperationInProgress: true,
    clearError: true,
  );
  try {
    if (subscribed) {
      await FirebaseMessaging.instance.subscribeToTopic('pengumuman-kampus');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic(
        'pengumuman-kampus',
      );
    }
    pushDebugState.value = pushDebugState.value.copyWith(
      topicSubscribed: subscribed,
      clearError: true,
    );
  } catch (error) {
    recordPushError(error);
  } finally {
    pushDebugState.value = pushDebugState.value.copyWith(
      topicOperationInProgress: false,
    );
  }
}

Future<void> recordTokenSentToBackend(String token, {required Dio dio}) async {
  await dio.post<void>(
    '/devices',
    data: {'fcm_token': token, 'platform': 'android'},
  );
  pushDebugState.value = pushDebugState.value.copyWith(
    currentTokenPreview: _tokenPreview(token),
    lastSentTokenPreview: _tokenPreview(token),
    lastSentAt: DateTime.now(),
    clearError: true,
  );
}

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  String? token;
  try {
    // FCM registration token is required by the Praktikum 2 backend flow.
    // ignore: deprecated_member_use
    token = await FirebaseMessaging.instance.getToken();
  } catch (error) {
    recordPushError(error);
  }
  if (token != null) {
    _recordCurrentToken(token);
    try {
      await onToken(token);
    } catch (error) {
      recordPushError(error);
    }
  }

  // ignore: deprecated_member_use
  _tokenRefreshSubscription ??= FirebaseMessaging.instance.onTokenRefresh
      .listen(
        (refreshedToken) {
          pushDebugState.value = pushDebugState.value.copyWith(
            currentTokenPreview: _tokenPreview(refreshedToken),
            refreshCount: pushDebugState.value.refreshCount + 1,
            clearError: true,
          );
          unawaited(_sendRefreshedToken(onToken, refreshedToken));
        },
        onError: (Object error) {
          recordPushError(error);
        },
      );

  await setAnnouncementTopicSubscription(true);
}

Future<void> _sendRefreshedToken(
  Future<void> Function(String token) onToken,
  String token,
) async {
  try {
    await onToken(token);
  } catch (error) {
    recordPushError(error);
  }
}
