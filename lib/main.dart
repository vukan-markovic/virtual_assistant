import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:virtual_assistant/chatbot.dart';
import 'package:virtual_assistant/localization.dart';
import 'package:virtual_assistant/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) => Localization.of(context).title,
      home: MyHomePage(),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xffF44336),
        primaryColorDark: Color(0xffD32F2F),
        primaryColorLight: Color(0xffFFCDD2),
        dividerColor: Color(0xffBDBDBD),
        accentColor: Color(0xffFF4081),
        iconTheme: IconThemeData(color: Color(0xffFFFFFF)),
        textTheme: GoogleFonts.sourceSansProTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      localizationsDelegates: [
        const DemoLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
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
  FirebaseUser _currentUser;

  initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null)
      return Login();
    else
      return Chatbot(user: _currentUser);
  }
}
