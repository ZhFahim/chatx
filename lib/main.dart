import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home.dart';
import 'screens/chat.dart';
import 'package:chatx/screens/roomMenu.dart';

void main() {
  runApp(ChatX());
}

class ChatX extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatX',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        accentColor: Color(0xFF1AF79B),
        canvasColor: Color(0xFF191A4D),
        appBarTheme: AppBarTheme(color: Color(0xFF191A4D), elevation: 0),
        fontFamily: 'HelveticaNeue',
        dialogTheme: DialogTheme(backgroundColor: Color(0xFF191A4D)),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF000133),
          contentTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'HelveticaNeueLight',
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) => HomeScreen(),
        'chatScreen': (context) => ChatScreen(ModalRoute.of(context).settings.arguments),
        'roomMenuScreen': (context) => RoomMenuScreen(ModalRoute.of(context).settings.arguments),
      },
    );
  }
}
