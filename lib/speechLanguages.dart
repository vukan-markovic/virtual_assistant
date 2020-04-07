import 'package:flutter/material.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';
import 'package:virtual_assistant/localization.dart';

class SpeechLanguages extends StatefulWidget {
  SpeechLanguages({Key key, this.speechLanguages}) : super(key: key);

  final Map<String, String> speechLanguages;

  @override
  _SpeechLanguagesState createState() => _SpeechLanguagesState();
}

class _SpeechLanguagesState extends State<SpeechLanguages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.of(context).languages),
      ),
      body: SingleChildScrollView(
        child: RadioSettingsTile(
          settingKey: 'radiokeyspeak',
          title: Localization.of(context).speechLanguage,
          values: widget.speechLanguages,
        ),
      ),
    );
  }
}
