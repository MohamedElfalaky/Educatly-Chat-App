import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../cache_services.dart';

class FcmService {
  FcmService._internal();

  static final FcmService _instance = FcmService._internal();

  factory FcmService() {
    return _instance;
  }
  final CacheServices _cach = CacheServices.instance;

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> registerNotification() async {
    await firebaseMessaging.requestPermission();
    await firebaseMessaging.getToken().then((token) {
      _cach.setDeviceToken(token!);
      debugPrint("device token is $token");
    }).catchError((err) {});

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {}
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);

      // print(message.notification!.android!.clickAction);

      return;
    });
  }

  Future? showNotification(RemoteMessage? remoteNotification) async {
    // if (remoteNotification?.data["isChat"] == "1") {
    //   print("render chat ${Globals.appGloballKey.currentState!.context}");
    //   print("render chat ${Globals.appGloballKey.currentContext}");
    // }

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      "chat_test",
      "chat_test_channel",
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.max,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
    DarwinNotificationDetails darwinNotificationDetails =
        const DarwinNotificationDetails(
            categoryIdentifier: 'textCategory', presentSound: true);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification!.notification?.title,
      remoteNotification.notification?.body,
      platformChannelSpecifics,
      payload: null,
    );
  }

  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}
