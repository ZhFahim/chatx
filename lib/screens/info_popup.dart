import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InfoPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Info'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ChatX Version: 1.0',
            style: TextStyle(fontFamily: 'HelveticaNeueLight'),
          ),
          SizedBox(height: 25),
          FlatButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  fullscreenDialog: true,
                  builder: (context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text('Terms & Conditions'),
                      ),
                      body: WebView(
                        initialUrl: 'https://sites.google.com/view/chatx-terms-of-use/home',
                        javascriptMode: JavascriptMode.unrestricted,
                      ),
                    );
                  },
                ),
              );
            },
            child: Text('Terms & Conditions of use'),
          ),
          FlatButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  fullscreenDialog: true,
                  builder: (context) {
                    return Scaffold(
                      appBar: AppBar(
                        title: Text('Privacy Policy'),
                      ),
                      body: WebView(
                        initialUrl: 'https://sites.google.com/view/chatx-privacypolicy/home',
                        javascriptMode: JavascriptMode.unrestricted,
                      ),
                    );
                  },
                ),
              );
            },
            child: Text('Privacy Policy'),
          ),
          FlatButton(
            minWidth: 0,
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Dismiss',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
