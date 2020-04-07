import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
}
