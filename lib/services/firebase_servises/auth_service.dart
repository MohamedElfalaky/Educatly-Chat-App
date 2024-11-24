import 'dart:developer';

import 'package:chat_test/services/cache_services.dart';
import 'package:chat_test/services/my_application.dart';
import 'package:chat_test/services/pre_app_config.dart';
import 'package:chat_test/utils/globals.dart';
import 'package:chat_test/views/home_screen.dart';
import 'package:chat_test/views/login/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService {
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  Future<void> userRegister(
      {required String mail,
      required String password,
      required String username}) async {
    MyApplication.showLoadingDialog(Globals.navigatorKey.currentContext!);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: mail, password: password);

      await createUserDoc(userCredential, username);

      Navigator.pop(Globals.navigatorKey.currentContext!);

      MyApplication.showToastView(message: "You have registered successfully");

      await FirebaseAuth.instance.currentUser!.sendEmailVerification();

      MyApplication.navigateToRemove(
          Globals.navigatorKey.currentContext!, HomeScreen());

      // CacheServices.instance.setName(userCredential.user!.);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(Globals.navigatorKey.currentContext!);

      MyApplication.showToastView(message: e.code);
    } catch (e) {
      Navigator.pop(Globals.navigatorKey.currentContext!);

      MyApplication.showToastView(message: e.toString());
    }
  }

  Future<void> createUserDoc(
      UserCredential? userCredential, String username) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email,
        'name': username,
        'lastSeen': FieldValue.serverTimestamp(),
        'uid': userCredential.user!.uid,
        "online": false,
        "fcmToken": ''
      });
    }
  }

  Future<void> userLogin(String mail, String password) async {
    MyApplication.showLoadingDialog(Globals.navigatorKey.currentContext!);

    try {
      final fcmToken = CacheServices.instance.getDeviceToken();
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: mail, password: password);

      log('$fcmToken');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({
        'lastSeen': FieldValue.serverTimestamp(),
        "online": true,
        "fcmToken": fcmToken
      });

      Navigator.pop(Globals.navigatorKey.currentContext!);

      MyApplication.showToastView(message: "You have logged in successfully");

      //cach user data
      CacheServices.instance.setUid(userCredential.user!.uid);
      uId = userCredential.user!.uid;
      MyApplication.navigateToRemove(
          Globals.navigatorKey.currentContext!, HomeScreen());
    } on FirebaseAuthException catch (e) {
      Navigator.pop(Globals.navigatorKey.currentContext!);

      MyApplication.showToastView(message: e.code);
    }
  }

  Future<void> signOut() async {
    MyApplication.showLoadingDialog(Globals.navigatorKey.currentContext!);

    await FirebaseAuth.instance.signOut();

    Navigator.pop(Globals.navigatorKey.currentContext!);

    MyApplication.showToastView(message: "Logged out successfully");
    MyApplication.navigateToRemove(
        Globals.navigatorKey.currentContext!, LoginScreen());
  }
}
