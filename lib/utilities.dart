import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'localization.dart';

class Utilities {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.pinkAccent,
      textColor: Colors.white,
    );
  }

  static void pushPage(BuildContext context, Widget page) =>
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => page),
      );

  static void pushWebPage(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => new WebviewScaffold(
          url: url,
          appBar: new AppBar(
            title: Text(
              Localization.of(context).title,
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ),
      ),
    );
  }
}
