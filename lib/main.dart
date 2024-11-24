import 'package:chat_test/firebase_options.dart';
import 'package:chat_test/services/cache_services.dart';
import 'package:chat_test/services/firebase_servises/fcm_service.dart';
import 'package:chat_test/services/firebase_servises/firestore_services.dart';
import 'package:chat_test/services/pre_app_config.dart';
import 'package:chat_test/utils/globals.dart';
import 'package:chat_test/views/chat/presentation/chat_screen.dart';
import 'package:chat_test/views/home_screen.dart';
import 'package:chat_test/views/login/login_screen.dart';
import 'package:chat_test/views/registration/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  FcmService().showNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // to lock app in portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await preAppConfig();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUid();
    WidgetsBinding.instance.addObserver(this);

    // Set the user as online when the app starts
    FireStoreServices().setUserOnlineStatus(true);
  }

  @override
  void dispose() {
    // Set the user as offline when the app is closed
    FireStoreServices().setUserOnlineStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground
      FireStoreServices().setUserOnlineStatus(true);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      // App is in the background or closed
      FireStoreServices().setUserOnlineStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Globals.navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: uId != null ? const HomeScreen() : LoginScreen(),
    );
  }
}
