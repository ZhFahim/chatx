import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:chatx/widgets/leaveAlert.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatx/constants.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class RoomMenuScreen extends StatelessWidget {
  RoomMenuScreen(this.roomId);
  final roomId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Room ${roomId.substring(0, 8)}',
                      style:
                          TextStyle(color: Color(0xFFFFBF59), fontSize: 28.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    child: Icon(Icons.close),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(
                color: Colors.white,
                height: 30.0,
                thickness: 0.8,
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Invite people'),
                      onTap: () {
                        Share.share(
                          'Join my private chat room on ChatX.\nRoom ID: ${roomId.substring(0, 8)}',
                          subject: 'Invitation to join a private chat room',
                        );
                      },
                    ),
                    StreamBuilder(
                        stream: firestore
                            .collection('rooms/$roomId/members')
                            .orderBy('joinedAt')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              title: Text('Members'),
                            );
                          }
                          final members = snapshot.data.documents;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('Members (${snapshot.data.size})'),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () => Navigator.pop(context),
                                        child: Container(
                                          color: Theme.of(context).canvasColor,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          width: double.maxFinite,
                                          child:
                                              Icon(Icons.keyboard_arrow_down),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          padding: EdgeInsets.all(20.0),
                                          itemCount: members.length,
                                          itemBuilder: (context, index) =>
                                              ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(
                                              members[index]['username'],
                                              style: TextStyle(
                                                  color: colors[members[index]
                                                      ['username']]),
                                            ),
                                            subtitle: Text(
                                              'Joined at: ${members[index]['joinedAt'].toDate().toLocal().toString().substring(0, 16)}',
                                              style: TextStyle(
                                                fontFamily:
                                                    'HelveticaNeueLight',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Leave room',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => LeaveAlert(roomId: roomId),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
