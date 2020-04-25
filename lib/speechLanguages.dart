import 'package:flutter/material.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';
import 'package:virtual_assistant/ad.dart';
import 'package:virtual_assistant/localization.dart';

class SpeechLanguages extends StatefulWidget {
  SpeechLanguages({Key key, this.speechLanguages}) : super(key: key);

  final Map<String, String> speechLanguages;

  @override
  _SpeechLanguagesState createState() => _SpeechLanguagesState();
}

class _SpeechLanguagesState extends State<SpeechLanguages> {
  Ad ad = new Ad();

  @override
  void initState() {
    super.initState();
    ad.incrementCounter('speech').then((onValue) {
      if (onValue == 1) ad.showAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Localization.of(context).languages),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: RadioSettingsTile(
            settingKey: 'radiokeyspeak',
            title: Localization.of(context).speechLanguage,
            values: widget.speechLanguages,
          ),
        ),
      ),
    );
  }
}
