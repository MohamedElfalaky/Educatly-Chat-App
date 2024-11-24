import 'package:flutter/material.dart';

class Globals {
  static final GlobalKey<ScaffoldMessengerState> appGloballKey =
      GlobalKey<ScaffoldMessengerState>();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(); // used to get global context
}

Widget appLoader = Center(child: CircularProgressIndicator());
