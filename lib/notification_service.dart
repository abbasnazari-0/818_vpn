import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Request notification permissions
    await _firebaseMessaging.requestPermission();
    await _firebaseMessaging.subscribeToTopic('all'); // Subscribe to a topic

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/notif_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen(_onMessage);

    // Handle background/terminated notifications
    // FirebaseMessaging.onMessageOpenedApp
    //     .listen(_onNotificationTap as void Function(RemoteMessage event)?);
    // FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Get the FCM token (optional, for debugging or sending messages)
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');
  }

  void _onMessage(RemoteMessage message) {
    if (message.notification != null) {
      _showNotification(
        message.notification!.title ?? 'No Title',
        message.notification!.body ?? 'No Body',
      );
    }
  }

  void _onNotificationTap(NotificationResponse? response) {
    // Handle notification tap (e.g., navigate to a specific screen)
    print('Notification tapped: ${response?.payload}');
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel', // Channel ID
      'Default', // Channel name
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }
}
