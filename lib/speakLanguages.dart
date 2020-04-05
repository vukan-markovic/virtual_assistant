import 'package:flutter/material.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';

class SpeachLanguages extends StatefulWidget {
  SpeachLanguages({Key key, this.title, this.language, this.speakLanguages})
      : super(key: key);

  final String title;
  final String language;
  final Map<String, String> speakLanguages;

  @override
  _SpeachLanguagesState createState() => _SpeachLanguagesState();
}

class _SpeachLanguagesState extends State<SpeachLanguages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(title: new Text("Languages")),
        body: SingleChildScrollView(
          child: RadioSettingsTile(
              settingKey: 'radiokeyspeak',
              title: 'Select your speach language',
              values: widget.speakLanguages),
        ));
  }
}
