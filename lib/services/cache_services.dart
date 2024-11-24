import 'dart:convert';
import 'dart:developer';
import 'package:chat_test/services/firebase_servises/auth_service.dart';
import 'package:chat_test/services/firebase_servises/firestore_services.dart';
import 'package:chat_test/services/my_application.dart';
import 'package:chat_test/services/pre_app_config.dart';
import 'package:chat_test/views/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CacheServices {
  CacheServices._private();
  static CacheServices get instance {
    return _instance;
  }

  late FlutterSecureStorage storage;
  late SharedPreferences prefs;

  static final CacheServices _instance = CacheServices._private();

  // CacheServices() {
  //   init();
  // }

  Future<void> init() async {
    AndroidOptions getAndroidOptions() =>
        const AndroidOptions(encryptedSharedPreferences: true);
    storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    await SharedPreferences.getInstance().then((value) async => prefs = value);
  }

// save user id
  setUid(String uid) async {
    try {
      await storage.write(key: 'uid', value: uid);
    } catch (e) {
      print('cant save uid');
    }
  }

  Future<String?> getUid() async {
    try {
      String? uid = await storage.read(key: 'uid');
      return uid;
    } catch (e) {
      print('cant get uid');
    }
  }

  // logout
  logOut(BuildContext context) async {
    uId = null;
    await storage.deleteAll();
    await prefs.clear();
    FireStoreServices().setUserOnlineStatus(false);

    await AuthService().signOut();

    MyApplication.navigateToRemove(context, const LoginScreen());
  }

///// device token /////

  Future<bool> setDeviceToken(String deviceToken) async {
    try {
      await prefs.setString('deviceToken', deviceToken);
      return true;
    } catch (e) {
      log(e.toString(), name: 'CacheService::setdeviceToken');
      return false;
    }
  }

  String? getDeviceToken() {
    String? dToken;
    try {
      // String? json = prefs.getString('token');
      String? json = prefs.getString('deviceToken');
      if (json != null) {
        dToken = json;
      } else {
        log('Device token not loaded', name: 'CacheService::getDeviceToken');
      }
    } catch (e) {
      log(e.toString(), name: 'CacheService::getDeviceToken');
    }
    return dToken;
  }
}
