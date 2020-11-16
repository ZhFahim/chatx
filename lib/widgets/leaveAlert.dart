import 'package:flutter/material.dart';
import 'package:chatx/utils/chatBrain.dart';

class LeaveAlert extends StatefulWidget {
  @override
  _LeaveAlertState createState() => _LeaveAlertState();
  LeaveAlert({@required this.roomId});
  final roomId;
}

class _LeaveAlertState extends State<LeaveAlert> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? WillPopScope(
            onWillPop: () async => false,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : AlertDialog(
            title: Text('Leave the room?'),
            content: Text(
              'Chat will be destroyed if there is no member left in the room.',
              style: TextStyle(fontFamily: 'HelveticaNeueLight'),
            ),
            actions: [
              FlatButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text('Leave'),
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  ChatBrain().leaveRoom(context, roomId: widget.roomId);
                },
              ),
            ],
          );
  }
}
