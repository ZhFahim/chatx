import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(ChatX());
}

class ChatX extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatX',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        accentColor: Color(0xFF1AF79B),
        canvasColor: Color(0xFF2E2F8B),
        appBarTheme: AppBarTheme(color: Color(0xFF2E2F8B), elevation: 0),
        fontFamily: 'Helvetica Neue',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatX'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: FlatButton(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Create Room',
                  style: TextStyle(color: Theme.of(context).canvasColor),
                ),
                color: Theme.of(context).accentColor,
                onPressed: () {},
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: FlatButton(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Join a Room',
                  style: TextStyle(color: Theme.of(context).canvasColor),
                ),
                color: Theme.of(context).accentColor,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Information',
        child: Icon(Icons.info_outlined),
      ),
    );
  }
}
