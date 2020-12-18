import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InfoPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.all(15.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 25.0,
              left: 18.0,
              bottom: 5.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  'ChatX',
                  style: TextStyle(fontSize: 20.0),
                ),
                SizedBox(width: 5.0),
                Text(
                  '1.0',
                  style: TextStyle(
                    fontFamily: 'HelveticaNeueLight',
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Divider(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5.0),
          ListTile(
            dense: true,
            onTap: () {
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
                        initialUrl:
                            'https://sites.google.com/view/chatx-terms-of-use/home',
                        javascriptMode: JavascriptMode.unrestricted,
                      ),
                    );
                  },
                ),
              );
            },
            title: Text('Terms & Conditions'),
          ),
          ListTile(
            dense: true,
            onTap: () {
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
                        initialUrl:
                            'https://sites.google.com/view/chatx-privacypolicy/home',
                        javascriptMode: JavascriptMode.unrestricted,
                      ),
                    );
                  },
                ),
              );
            },
            title: Text('Privacy Policy'),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Text(
            'Dismiss',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
