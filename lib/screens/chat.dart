import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chatx/screens/roomMenu.dart';
import 'package:chatx/widgets/leaveAlert.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatx/constants.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseStorage storage = FirebaseStorage.instance;

class ChatScreen extends StatelessWidget {
  final TextEditingController msgController = TextEditingController();

  ChatScreen(this.roomId);
  final roomId;

  @override
  Widget build(BuildContext context) {
    bool isTyping = false;
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
                          style: TextStyle(color: Color(0xFFFFBF59), fontSize: 28.0),
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
                              pageBuilder: (context, animation, secondaryAnimation) {
                                return RoomMenuScreen(roomId);
                              },
                              transitionsBuilder: (context, animation, secondaryAnimation, child) => Align(
                                child: SlideTransition(
                                  position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
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
                    stream: firestore.collection('rooms/$roomId/chats').orderBy('createdAt', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        dynamic chats;
                        if (snapshot.data == null) {
                          chats = List<Widget>();
                        } else {
                          chats = snapshot.data.documents;
                        }

                        return ListView.builder(
                            reverse: true,
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            itemCount: chats.length,
                            itemBuilder: (context, index) {
                              return ChatBubble(
                                type: chats[index]['type'],
                                text: chats[index]['text'],
                                username: chats[index]['username'],
                                isSentMsg: chats[index]['uid'] == auth.currentUser.uid,
                                timestamp: chats[index]['createdAt'],
                              );
                            });
                      }
                    },
                  ),
                ),
                Container(
                  height: 30.0,
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                  child: StreamBuilder(
                      stream: firestore.collection('rooms/$roomId/members').where('isTyping', isEqualTo: true).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
                          return Container();
                        }
                        // if no one is typing
                        if (snapshot.data.documents.isEmpty) {
                          return Container();
                        }
                        // if only current user is typing
                        if (snapshot.data.size == 1 && snapshot.data.documents[0].data()['uid'] == auth.currentUser.uid) {
                          return Container();
                        }
                        return Container(
                          child: Text(
                            'Someone is typing...',
                            style: TextStyle(
                              fontFamily: 'HelveticaNeueLight',
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
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
                            contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
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
                          buildCounter: (context, {currentLength, isFocused, maxLength}) {
                            if (!isFocused || currentLength == 0) {
                              isTyping = false;
                              print('not typing...');
                              firestore.collection('rooms/$roomId/members').where('uid', isEqualTo: auth.currentUser.uid).get().then((member) {
                                firestore.doc('rooms/$roomId/members/${member.docs.first.id}').update({'isTyping': false});
                              });
                            } else if (isTyping == false) {
                              isTyping = true;
                              print('typing...');
                              firestore.collection('rooms/$roomId/members').where('uid', isEqualTo: auth.currentUser.uid).get().then((member) async {
                                firestore.doc('rooms/$roomId/members/${member.docs.first.id}').update({'isTyping': true});
                              });
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                          textColor: Theme.of(context).accentColor,
                          child: Icon(Icons.photo),
                          onPressed: () async {
                            final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
                            if (pickedImage != null) {
                              File selectedImage = File(pickedImage.path);
                              String extension = pickedImage.path.split('.').last;
                              await firestore.collection('rooms/$roomId/chats/').add({
                                'type': 'text',
                                'text': '[uploading image]',
                                'uid': auth.currentUser.uid,
                                'username': auth.currentUser.displayName,
                                'createdAt': Timestamp.now(),
                              }).then((text) {
                                String url;
                                storage.ref('images/$roomId/${text.id}.$extension').putFile(selectedImage).then((image) async {
                                  url = await image.ref.getDownloadURL();
                                }).then((value) {
                                  text.update({
                                    'type': 'image',
                                    'text': url,
                                  });
                                });
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: FlatButton(
                          padding: EdgeInsets.all(0),
                          textColor: Theme.of(context).accentColor,
                          child: Icon(Icons.send),
                          onPressed: () async {
                            final String message = msgController.text.trim();
                            if (message == '') {
                              return;
                            }
                            msgController.clear();
                            firestore.collection('rooms/$roomId/members').where('uid', isEqualTo: auth.currentUser.uid).get().then((member) {
                              firestore.doc('rooms/$roomId/members/${member.docs.first.id}').update({'isTyping': false});
                            });
                            await firestore.collection('rooms/$roomId/chats/').add({
                              'type': 'text',
                              'text': message,
                              'uid': auth.currentUser.uid,
                              'username': auth.currentUser.displayName,
                              'createdAt': Timestamp.now(),
                            });
                          },
                        ),
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
    @required this.type,
    @required this.text,
    @required this.username,
    @required this.isSentMsg,
    @required this.timestamp,
  }) : super(key: key);

  final String type;
  final String text;
  final String username;
  final bool isSentMsg;
  final Timestamp timestamp;

  @override
  Widget build(BuildContext context) {
    if (type == 'alert') {
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
          type == 'image'
              ? Image.network(
                  text,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null)
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: child,
                      );
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
                      ),
                    );
                  },
                )
              : Text(
                  text,
                  style: TextStyle(fontFamily: 'HelveticaNeueLight', fontSize: 15.0),
                ),
        ],
      ),
    );
  }
}
