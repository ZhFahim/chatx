import 'dart:ui';
import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/chat.dart';

void main() {
  runApp(ChatX());
}

class ChatX extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        '/': (context) => HomeScreen(),
        'chatScreen': (context) => ChatScreen(),
      },
    );
  }
}
