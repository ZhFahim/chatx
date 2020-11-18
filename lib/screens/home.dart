import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatx/constants.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 0.0, vertical: 15.0),
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
                      subtitle:
                          Text('ID: ${Random().nextInt(999999).toString()}'),
                      dense: true,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                EnterRoomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EnterRoomSection extends StatefulWidget {
  const EnterRoomSection({Key key}) : super(key: key);

  @override
  _EnterRoomSectionState createState() => _EnterRoomSectionState();
}

class _EnterRoomSectionState extends State<EnterRoomSection> {
  Future<String> getUsername(String roomId) async {
    List<String> joinedColors = [];
    String color = colors.keys.toList()[Random().nextInt(colors.length)];
    await firestore.collection('rooms/$roomId/members').get().then((value) {
      value.docs.forEach((element) {
        joinedColors.add(element.data()['username']);
      });
    });
    while (joinedColors.contains(color)) {
      color = colors.keys.toList()[Random().nextInt(colors.length)];
    }
    return color;
  }

  final TextEditingController roomIdController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      setState(() {
                        isLoading = true;
                      });
                      FocusScope.of(context).unfocus();
                      firestore
                          .collection('rooms')
                          .where('roomId',
                              isEqualTo: roomIdController.text.trim())
                          .get()
                          .then((result) {
                        if (result.docs.isNotEmpty) {
                          firestore
                              .collection(
                                  'rooms/${result.docs.first.id}/members')
                              .get()
                              .then((value) {
                            if (value.size < 10) {
                              auth.signOut().then((value) {
                                auth.signInAnonymously().then((value) async {
                                  String username =
                                      await getUsername(result.docs.first.id);
                                  await auth.currentUser
                                      .updateProfile(displayName: username);
                                  await firestore
                                      .collection(
                                          'rooms/${result.docs.first.id}/members')
                                      .add({
                                    'uid': auth.currentUser.uid,
                                    'username': username,
                                    'joinedAt': Timestamp.now(),
                                  });
                                  await firestore
                                      .collection(
                                          'rooms/${result.docs.first.id}/chats')
                                      .add({
                                    'type': 'alert',
                                    'text': '$username has entered the room',
                                    'uid': auth.currentUser.uid,
                                    'username': 'system',
                                    'createdAt': Timestamp.now(),
                                  });
                                  Navigator.pushNamed(
                                    context,
                                    'chatScreen',
                                    arguments: result.docs.first.id,
                                  ).then((value) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  });
                                });
                              });
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Maximum 10 members can enter in a room'),
                              ));
                            }
                          });
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Room not found!'),
                          ));
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
                                style: TextStyle(
                                    color: Theme.of(context).canvasColor),
                              ),
                              color: Theme.of(context).accentColor,
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                auth.signOut().then((value) {
                                  auth.signInAnonymously().then((value) async {
                                    var room =
                                        await firestore.collection('rooms').add(
                                      {},
                                    );
                                    String username =
                                        await getUsername(room.id);
                                    await auth.currentUser
                                        .updateProfile(displayName: username);
                                    await firestore
                                        .collection('rooms/${room.id}/members')
                                        .add({
                                      'uid': auth.currentUser.uid,
                                      'username': username,
                                      'joinedAt': Timestamp.now(),
                                    });
                                    await firestore
                                        .doc('rooms/${room.id}')
                                        .update({
                                      'roomId': room.id.substring(0, 8)
                                    });
                                    await firestore
                                        .collection('rooms/${room.id}/chats')
                                        .add({
                                      'type': 'alert',
                                      'text': '$username has created the room',
                                      'uid': auth.currentUser.uid,
                                      'username': 'system',
                                      'createdAt': Timestamp.now(),
                                    });
                                    Navigator.pushNamed(
                                      context,
                                      'chatScreen',
                                      arguments: room.id,
                                    ).then((value) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    });
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
    );
  }
}
