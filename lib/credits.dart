import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:virtual_assistant/utilities.dart';

class Credits extends StatefulWidget {
  Credits({Key key}) : super(key: key);

  @override
  _CreditsState createState() => _CreditsState();
}

class _CreditsState extends State<Credits> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Credits"),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'All icons are made by Freepik from ',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: 'www.flaticon.com',
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Utilities.pushWebPage(
                          context, 'https://www.flaticon.com');
                    },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
