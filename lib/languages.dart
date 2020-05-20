import 'package:flutter/material.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';
import 'package:virtual_assistant/ad.dart';

class Languages extends StatefulWidget {
  Languages({Key key}) : super(key: key);

  @override
  _LanguagesState createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  Ad ad = new Ad();

  @override
  void initState() {
    super.initState();
    ad.incrementCounter('language').then((onValue) {
      if (onValue == 1) ad.showAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Assistant language"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: RadioSettingsTile(
            settingKey: 'radiokey',
            title: 'Select language',
            values: {
              'af': 'Afrikaans',
              'sq': 'Albanian',
              'ar': 'Arabic',
              'az': 'Azerbaijani',
              'eu': 'Basque',
              'be': 'Belarusian',
              'bn': 'Bengali',
              'bg': 'Bulgarian',
              'ca': 'Catalan',
              'zh-CN': 'Chinese (Simplified)',
              'zh-TW': 'Chinese (Traditional)',
              'hr': 'Croatian',
              'cs': 'Czech',
              'da': 'Danish',
              'nl': 'Dutch',
              'en': 'English',
              'eo': 'Esperanto',
              'et': 'Estonian',
              'tl': 'Filipino',
              'fi': 'Finnish',
              'fr': 'French',
              'gl': 'Galician',
              'ka': 'Georgian',
              'de': 'German',
              'el': 'Greek',
              'gu': 'Gujarati',
              'ht': 'Haitian Creole',
              'iw': 'Hebrew',
              'hi': 'Hindi',
              'hu': 'Hungarian',
              'is': 'Icelandic',
              'id': 'Indonesian',
              'ga': 'Irish',
              'it': 'Italian',
              'ja': 'Japanese',
              'kn': 'Kannada',
              'ko': 'Korean',
              'la': 'Latin',
              'lv': 'Latvian',
              'lt': 'Lithuanian',
              'mk': 'Macedonian',
              'ms': 'Malay',
              'mt': 'Maltese',
              'no': 'Norwegian (Bokmål)',
              'fa': 'Persian',
              'pl': 'Polish',
              'pt': 'Portuguese',
              'ro': 'Romanian',
              'ru': 'Russian',
              'sr': 'Serbian',
              'sk': 'Slovak',
              'sl': 'Slovenian',
              'es': 'Spanish',
              'sw': 'Swahili',
              'sv': 'Swedish',
              'ta': 'Tamil',
              'te': 'Telugu',
              'th': 'Thai',
              'tr': 'Turkish',
              'uk': 'Ukrainian',
              'ur': 'Urdu',
              'vi': 'Vietnamese',
              'cy': 'Welsh',
              'yi': 'Yiddish'
            },
          ),
        ),
      ),
    );
  }
}
