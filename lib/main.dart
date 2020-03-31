import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_assistant/chatbot.dart';
import 'package:virtual_assistant/login.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Virtual assistant',
      theme: new ThemeData(
          primarySwatch: Colors.red, accentColor: Colors.redAccent),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

   @override
  initState() {
    super.initState();
    isLoggedIn();
  }

  void isLoggedIn() async {
    final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    if (currentUser != null)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => Chatbot(user: currentUser)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SignInPage();
  }
}