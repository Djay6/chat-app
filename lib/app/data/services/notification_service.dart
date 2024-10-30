import 'dart:convert';

import 'package:chat_app/app/routes/app_pages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

class NotificationService extends GetxService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle iOS foreground notification
      },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // if (details.payload != null) {
        //   final payload = jsonDecode(details.payload!);
        //   Get.toNamed(
        //     Routes.CHAT,
        //     arguments: {
        //       'chatId': payload['chatId'],
        //       'userId': payload['userId'],
        //       'userName': payload['userName'],
        //     },
        //   );
        // }
      },
    );

    // Set up FCM foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: {
          'chatId': message.data['chatId'],
          'userId': message.data['userId'],
          'userName': message.data['userName'],
        },
      );
    });
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    if (Get.currentRoute.startsWith('/chat') &&
        Get.arguments?['chatId'] == payload['chatId']) {
      return;
    }

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'messages',
          'Messages',
          channelDescription: 'Notifications for chat messages',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableLights: true,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(payload),
    );
  }
}
