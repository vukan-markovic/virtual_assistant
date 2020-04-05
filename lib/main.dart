import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_assistant/chatbot.dart';
import 'package:virtual_assistant/localization.dart';
import 'package:virtual_assistant/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(new MyApp());

enum AuthStatus {
  notSignedIn,
  signedIn,
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      onGenerateTitle: (BuildContext context) =>
          DemoLocalizations.of(context).title,
      home: MyHomePage(),
      theme: new ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.green,
          primarySwatch: Colors.red,
          accentColor: Colors.redAccent,
          textTheme: GoogleFonts.quicksandTextTheme(
            Theme.of(context).textTheme,
          )),
      localizationsDelegates: [
        const DemoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('it', ''),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseUser currentUser;

  AuthStatus authStatus = AuthStatus.notSignedIn;

  initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        authStatus =
            user != null ? AuthStatus.signedIn : AuthStatus.notSignedIn;
        currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return SignInPage();
      case AuthStatus.signedIn:
        return Chatbot(user: currentUser);
      default:
        return null;
    }
  }
}
