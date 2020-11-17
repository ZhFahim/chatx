import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chatx/screens/roomMenu.dart';
import 'package:chatx/widgets/leaveAlert.dart';
import 'package:chatx/constants.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class ChatScreen extends StatelessWidget {
  final TextEditingController msgController = TextEditingController();

  ChatScreen(this.roomId);
  final roomId;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => showDialog(
        context: context,
        builder: (context) => LeaveAlert(roomId: roomId),
      ),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          'Room ${roomId.substring(0, 8)}',
                          style: TextStyle(
                              color: Color(0xFFFFBF59), fontSize: 28.0),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        child: Icon(Icons.menu),
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                return RoomMenuScreen(roomId);
                              },
                              transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) =>
                                  Align(
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero)
                                      .animate(animation),
                                  child: child,
                                ),
                              ),
                              transitionDuration: Duration(milliseconds: 300),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Divider(
                    color: Colors.white,
                    height: 30.0,
                    thickness: 0.8,
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: firestore
                        .collection('rooms/$roomId/chats')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        final chats = snapshot.data.documents;
                        return ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          itemCount: chats.length,
                          itemBuilder: (context, index) =>
                              // children: [
                              //   Padding(
                              //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              //     child: Text('Beginning of the converstaion'),
                              //   ),
                              //   SizedBox(height: 5.0),
                              //   Padding(
                              //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              //     child: Text('Wednesday, November 11, 10:34 PM'),
                              //   ),
                              //   SizedBox(height: 20.0),
                              ChatBubble(
                            text: chats[index]['text'],
                            username: chats[index]['username'],
                            isSentMsg:
                                chats[index]['uid'] == auth.currentUser.uid,
                            timestamp: chats[index]['createdAt'],
                          ),
                        );
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: msgController,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'HelveticaNeueLight',
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'HelveticaNeueLight',
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).accentColor,
                                width: 5.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.0),
                      FlatButton(
                        padding: EdgeInsets.all(0),
                        textColor: Theme.of(context).accentColor,
                        child: Icon(Icons.send),
                        onPressed: () async {
                          final String message = msgController.text.trim();
                          if (message == '') {
                            return;
                          }
                          msgController.clear();
                          await firestore
                              .collection('rooms/$roomId/chats/')
                              .add({
                            'text': message,
                            'uid': auth.currentUser.uid,
                            'username': auth.currentUser.displayName,
                            'createdAt': Timestamp.now(),
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    Key key,
    @required this.text,
    @required this.username,
    @required this.isSentMsg,
    @required this.timestamp,
  }) : super(key: key);

  final String text;
  final String username;
  final bool isSentMsg;
  final Timestamp timestamp;

  @override
  Widget build(BuildContext context) {
    if (username == 'system') {
      return Container(
        margin: EdgeInsets.only(
          right: 20.0,
          left: 20.0,
          bottom: 15.0,
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Color(0xFF000133),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          text,
          style: TextStyle(color: Color(0xFFFFBF59)),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Container(
      margin: EdgeInsets.only(
        right: isSentMsg ? 0 : 20.0,
        left: isSentMsg ? 20.0 : 0,
        bottom: 15.0,
      ),
      padding: EdgeInsets.only(
        top: 20.0,
        bottom: 20.0,
        left: isSentMsg ? 10.0 : 20.0,
        right: 10.0,
      ),
      decoration: BoxDecoration(
        color: Color(0xFF000133),
        borderRadius: BorderRadius.only(
          topLeft: isSentMsg ? Radius.circular(10.0) : Radius.zero,
          topRight: isSentMsg ? Radius.zero : Radius.circular(10.0),
          bottomLeft: isSentMsg ? Radius.circular(10.0) : Radius.zero,
          bottomRight: isSentMsg ? Radius.zero : Radius.circular(10.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  username,
                  style: TextStyle(color: colors[username]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                timestamp.toDate().toLocal().toString().substring(0, 16),
                style: TextStyle(
                  fontSize: 12.0,
                  fontFamily: 'HelveticaNeueLight',
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Text(
            text,
            style: TextStyle(fontFamily: 'HelveticaNeueLight', fontSize: 15.0),
          ),
        ],
      ),
    );
  }
}
