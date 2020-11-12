import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Room Name',
                    style: TextStyle(color: Color(0xFFFFBF59), fontSize: 28.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.menu),
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
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text('Beginning of the converstaion'),
                  ),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text('Wednesday, November 11, 10:34 PM'),
                  ),
                  SizedBox(height: 20.0),
                  ChatBubble(isSentMsg: false),
                  ChatBubble(isSentMsg: true),
                  ChatBubble(isSentMsg: true),
                  ChatBubble(isSentMsg: false),
                  ChatBubble(isSentMsg: true),
                  ChatBubble(isSentMsg: false),
                  ChatBubble(isSentMsg: true),
                  ChatBubble(isSentMsg: false),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.black),
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
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Icon(Icons.send),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({Key key, @required this.isSentMsg}) : super(key: key);

  final isSentMsg;

  @override
  Widget build(BuildContext context) {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User ID',
                style: TextStyle(
                    color: isSentMsg
                        ? Theme.of(context).accentColor
                        : Color(0xFFFFBF59)),
              ),
              Text(
                'today, 10:46 PM',
                style: TextStyle(
                  fontSize: 12.0,
                  fontFamily: 'HelveticaNeueLight',
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            style: TextStyle(fontFamily: 'HelveticaNeueLight', fontSize: 15.0),
          ),
        ],
      ),
    );
  }
}
