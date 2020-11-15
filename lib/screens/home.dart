import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class HomeScreen extends StatelessWidget {
  final TextEditingController roomIdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
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
                  controller: roomIdController,
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
                    FocusScope.of(context).unfocus();
                    firestore
                        .collection('rooms')
                        .where('roomId', isEqualTo: roomIdController.text)
                        .get()
                        .then((result) {
                      if (result.docs.isNotEmpty) {
                        firestore
                            .collection('rooms/${result.docs.first.id}/members')
                            .get()
                            .then((value) {
                          if (value.size < 10) {
                            auth.signOut().then((value) {
                              auth.signInAnonymously().then((value) async {
                                await firestore
                                    .collection(
                                        'rooms/${result.docs.first.id}/members')
                                    .add({
                                  'uid': auth.currentUser.uid,
                                  'joinedAt': Timestamp.now(),
                                });
                                Navigator.pushNamed(
                                  context,
                                  'chatScreen',
                                  arguments: result.docs.first.id,
                                );
                              });
                            });
                          } else {
                            print('Maximum 10 members can enter in a room');
                          }
                        });
                      } else {
                        print('Room not found!');
                      }
                    });
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
                            onPressed: () {
                              // await firestore
                              //     .collection('rooms')
                              //     .where('roomId', isEqualTo: 'test')
                              //     .get()
                              //     .then((value) {
                              //   value.docs.forEach((element) {
                              //     print(element.id);
                              //   });
                              // });
                              auth.signOut().then((value) {
                                auth.signInAnonymously().then((value) async {
                                  print(value.user);
                                  var room =
                                      await firestore.collection('rooms').add(
                                    {},
                                  );
                                  await firestore
                                      .collection('rooms/${room.id}/members')
                                      .add({
                                    'uid': auth.currentUser.uid,
                                    'joinedAt': Timestamp.now(),
                                  });
                                  await firestore
                                      .doc('rooms/${room.id}')
                                      .update(
                                          {'roomId': room.id.substring(0, 8)});
                                  Navigator.pushNamed(
                                    context,
                                    'chatScreen',
                                    arguments: room.id,
                                  );
                                });
                              });
                            },
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
