import 'package:flutter/material.dart';
import 'package:megamix/Home.dart';
import 'RouteGenerator.dart';
import 'dart:io';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final ThemeData temaIOS =
      ThemeData(primaryColor: Colors.grey[200], accentColor: Color(0xff25D366));

  final ThemeData temaPadrao = ThemeData(
      primaryColor: Color(0xff075E54), accentColor: Color(0xff25D366));

  runApp(MaterialApp(
    home: Home(),
    theme: Platform.isIOS ? temaIOS : temaPadrao,
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
    debugShowCheckedModeBanner: false,
  ));
}
