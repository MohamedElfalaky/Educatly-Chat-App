import 'package:chat_test/firebase_options.dart';
import 'package:chat_test/main.dart';
import 'package:chat_test/services/cache_services.dart';
import 'package:chat_test/services/firebase_servises/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

/// Configuration that needs to be done before the Flutter app starts goes here.
///
/// To minimize the app loading time keep this setup fast and simple.
Future<void> preAppConfig() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await CacheServices.instance.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((e) async {
    FcmService noti = FcmService();
    await noti.registerNotification();
    noti.configLocalNotification();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  });

  await checkUid();
}

late String? uId;

checkUid() async {
  uId = await CacheServices.instance.getUid();
}
