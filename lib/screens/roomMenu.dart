import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:chatx/widgets/leaveAlert.dart';

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
