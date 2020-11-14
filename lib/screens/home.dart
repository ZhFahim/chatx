import 'dart:math';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Welcome',
                  style: TextStyle(fontSize: 28.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Divider(
                  color: Colors.white,
                  height: 30.0,
                  thickness: 0.8,
                ),
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Active Rooms',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              SizedBox(height: 15.0),
              Container(
                height: 200.0,
                margin: EdgeInsets.only(left: 20.0),
                decoration: BoxDecoration(
                  color: Color(0xFF000133),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  ),
                ),
                // Demo rooms
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) => ListTile(
                    title: Text('Room ${index + 1}'),
                    subtitle: Text('ID: ${Random().nextInt(999999).toString()}'),
                    dense: true,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  decoration: InputDecoration(labelText: 'Enter Room ID'),
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FlatButton(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Join Room',
                    style: TextStyle(color: Theme.of(context).canvasColor),
                  ),
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    Navigator.pushNamed(context, 'chatScreen');
                  },
                ),
              ),
              SizedBox(height: 5.0),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    height: 50.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'Create Room',
                              style: TextStyle(color: Theme.of(context).canvasColor),
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(width: 5.0),
                        Expanded(
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.settings,
                              color: Theme.of(context).canvasColor,
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
