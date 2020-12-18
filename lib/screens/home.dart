import 'dart:math';
import 'package:chatx/screens/info_popup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
        body: SafeArea(
          top: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: WelcomeMessage(),
                ),
                Expanded(child: EnterRoomSection()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeMessage extends StatefulWidget {
  const WelcomeMessage({
    Key key,
  }) : super(key: key);

  @override
  _WelcomeMessageState createState() => _WelcomeMessageState();
}

class _WelcomeMessageState extends State<WelcomeMessage>
    with TickerProviderStateMixin {
  AnimationController _animController;
  Animation<Offset> _animOffset;
  Animation<double> _animOpacity;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animOffset =
        Tween<Offset>(begin: const Offset(0.0, 5.0), end: Offset.zero).animate(
      CurvedAnimation(
          curve: Interval(0.0, 0.5, curve: Curves.decelerate),
          parent: _animController),
    );
    _animOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Interval(0.3, 1.0, curve: Curves.decelerate),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _animController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/anonymous_icon.png'),
          scale: 1.8,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SlideTransition(
            position: _animOffset,
            child: Text(
              'Welcome to ChatX',
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30.0),
          FadeTransition(
            opacity: _animOpacity,
            child: Text(
              'A platform where you can chat anonymously',
              style: TextStyle(fontSize: 20, fontFamily: 'HelveticaNeueLight'),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: roomIdController,
                    style: TextStyle(color: Colors.grey.shade800),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Enter Room ID',
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'HelveticaNeueLight',
                        fontWeight: FontWeight.bold,
                      ),
                      border: UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).accentColor,
                          width: 5.0,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  FlatButton(
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
                      auth.signOut().then((value) {
                        auth.signInAnonymously().then((value) {
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
                                  .then((value) async {
                                if (value.size < 10) {
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
                        });
                      });
                    },
                  ),
                  SizedBox(height: 30.0),
                  Container(
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
                                  String username = await getUsername(room.id);
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
                                      .update(
                                          {'roomId': room.id.substring(0, 8)});
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
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: Theme.of(context).canvasColor,
                            ),
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => InfoPopup(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
