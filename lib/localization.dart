import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

class Localization {
  Localization(this.locale);
  final Locale locale;

  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Virtual assistant',
      'languages': 'Languages',
      'speechLanguage': 'Select your speech language',
      'share': 'Share',
      'signOut': 'Sign out',
      'login': 'Login',
      'loginMessage': 'Sign in to chat with assistant'
    },
    'it': {
      'title': 'Assistente virtuale',
      'languages': 'Lingue',
      'speechLanguage': 'Select your speech language',
      'share': 'Share',
      'signOut': 'Sign out',
      'login': 'Login',
      'loginMessage': 'Sign in to chat with assistant'
    },
  };

  String get title {
    return _localizedValues[locale.languageCode]['title'];
  }

  String get languages {
    return _localizedValues[locale.languageCode]['languages'];
  }

  String get speechLanguage {
    return _localizedValues[locale.languageCode]['speechLanguage'];
  }

  String get share {
    return _localizedValues[locale.languageCode]['share'];
  }

  String get signOut {
    return _localizedValues[locale.languageCode]['signOut'];
  }

  String get login {
    return _localizedValues[locale.languageCode]['login'];
  }

  String get loginMessage {
    return _localizedValues[locale.languageCode]['loginMessage'];
  }
}

class DemoLocalizationsDelegate extends LocalizationsDelegate<Localization> {
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'it'].contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) {
    return SynchronousFuture<Localization>(Localization(locale));
  }

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}
