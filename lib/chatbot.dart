import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtual_assistant/languages.dart';
import 'package:virtual_assistant/localization.dart';
import 'package:virtual_assistant/login.dart';
import 'dart:io';
import 'package:virtual_assistant/message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';
import 'package:virtual_assistant/speechLanguages.dart';
import 'package:virtual_assistant/utilities.dart';
import 'package:android_intent/android_intent.dart';

class Chatbot extends StatefulWidget {
  Chatbot({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _ChatbotState createState() => _ChatbotState();
}

enum TtsState { playing, stopped }

class _ChatbotState extends State<Chatbot> with TickerProviderStateMixin {
  final flutterWebViewPlugin = FlutterWebviewPlugin();
  bool _isPressed = false;
  final List<Message> _messages = <Message>[];
  final TextEditingController _textController = TextEditingController();
  bool _isAnswered = true;
  File _image;
  FlutterTts _flutterTts;
  String _newVoiceText;
  TtsState _ttsState = TtsState.stopped;
  bool _hasSpeech = false;
  String _lastWords = "";
  String _currentLocaleId = "";
  final SpeechToText _speech = SpeechToText();
  Map<String, String> _speechLanguages = {};
  ImageLabeler _labeler = FirebaseVision.instance.imageLabeler();
  TextRecognizer _textRecognizer = FirebaseVision.instance.textRecognizer();
  bool _option = false;
  List<String> menuOptions = [];

  get isPlaying => _ttsState == TtsState.playing;
  get isStopped => _ttsState == TtsState.stopped;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text(
          Localization.of(context).title,
          style: TextStyle(fontSize: 18.0),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () => _getImage(ImageSource.gallery),
          ),
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: () => _getImage(ImageSource.camera),
          ),
          PopupMenuButton<String>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return menuOptions.map((String menuOption) {
                return PopupMenuItem<String>(
                  value: menuOption,
                  child: Text(menuOption),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('img/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Flexible(
                child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, int index) => _messages[index],
                  itemCount: _messages.length,
                ),
              ),
              Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                ),
                child: _buildTextComposer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  initState() {
    super.initState();
    _response("hi there", true);
    initMenu();
    _initTts();
    _initSpeechState();
  }

  void initMenu() {
    menuOptions = <String>[
      'Assistant language',
      'Your speach language',
      'Clear messages',
      'Sign out',
      'Delete account',
    ];
  }

  Route _createRoute(StatefulWidget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: animation.drive(
            Tween(
              begin: Offset(0.0, 1.0),
              end: Offset.zero,
            ).chain(
              CurveTween(curve: Curves.ease),
            ),
          ),
          child: child,
        );
      },
    );
  }

  Future<void> _initSpeechState() async {
    bool hasSpeech = await _speech.initialize();
    if (hasSpeech) {
      List<LocaleName> _localeNames = await _speech.locales();
      var systemLocale = await _speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
      for (var item in _localeNames)
        _speechLanguages[item.localeId] = item.name;
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  void _startListening() async {
    _lastWords = "";

    _currentLocaleId = await Settings().getString(
      'radiokey_speak',
      'en',
    );

    _speech.listen(
      onResult: _resultListener,
      localeId: _currentLocaleId,
    );

    setState(() {
      _isPressed = true;
    });
  }

  void _stopListening() {
    _speech.stop();

    setState(() {
      _isPressed = false;
    });
  }

  void _resultListener(SpeechRecognitionResult result) {
    if (!_speech.isListening && _lastWords != result.recognizedWords) {
      setState(() {
        _lastWords = result.recognizedWords;
        _isPressed = false;
      });
      _question(result.recognizedWords);
    }
  }

  _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setVolume(0.5);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setStartHandler(() {
      setState(() {
        _ttsState = TtsState.playing;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _ttsState = TtsState.stopped;
      });
    });

    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _ttsState = TtsState.stopped;
      });
    });
  }

  Future _speak() async {
    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        if (await _flutterTts.speak(_newVoiceText) == 1)
          setState(() => _ttsState = TtsState.playing);
      }
    }
  }

  @override
  void dispose() {
    _labeler.close();
    _textRecognizer.close();
    for (Message message in _messages) message.animationController.dispose();
    flutterWebViewPlugin.dispose();
    super.dispose();
    _flutterTts.stop();
  }

  void _select(String menuOption) {
    switch (menuOption) {
      case "Sign out":
        _signOut();
        break;
      case "Assistant language":
        Navigator.of(context).push(_createRoute(Languages()));
        break;
      case "Your speach language":
        Navigator.of(context).push(_createRoute(
          SpeechLanguages(
            speechLanguages: _speechLanguages,
          ),
        ));
        break;
      case "Clear messages":
        setState(() {
          _messages.clear();
        });
        break;
      case "Delete account":
        _deleteDialog();
        break;
    }
  }

  Future<void> _deleteDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Theme.of(context).primaryColorLight,
          title: Text(
            'Are you sure?',
            textAlign: TextAlign.center,
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  "Yes",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  widget.user.delete();
                  Utilities.showToast("Account is deleted!");
                  Utilities.pushPage(context, Login());
                },
              ),
            ),
            SimpleDialogOption(
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  'No',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> _detectLabels(File image) async {
    final List<ImageLabel> labels =
        await _labeler.processImage(FirebaseVisionImage.fromFile(image));
    List<String> texts = [];
    for (ImageLabel label in labels) texts.add(label.text);
    return texts;
  }

  Future<String> _detectText(File image) async {
    final VisionText visionText =
        await _textRecognizer.processImage(FirebaseVisionImage.fromFile(image));
    return visionText.text;
  }

  Future _getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _image = image;
      });
      _dialog();
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Utilities.pushPage(context, Login());
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(
        color: Theme.of(context).accentColor,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).accentColor,
              width: 2.0,
            ),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: <Widget>[
              Flexible(
                child: SafeArea(
                  child: TextField(
                    toolbarOptions: ToolbarOptions(
                      selectAll: false,
                      copy: true,
                      cut: true,
                      paste: true,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    controller: _textController,
                    onSubmitted: _question,
                    decoration: InputDecoration.collapsed(
                      hintText: "Send a message",
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).accentColor,
                  ),
                  tooltip: "Send",
                  onPressed: () {
                    _question(_textController.text);
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                    icon: Icon(
                      Icons.mic,
                      color: (_isPressed)
                          ? Theme.of(context).primaryColorDark
                          : Theme.of(context).accentColor,
                    ),
                    tooltip: "Microphone",
                    onPressed: _hasSpeech && !_speech.isListening
                        ? _startListening
                        : _stopListening),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _dialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Theme.of(context).primaryColorLight,
          title: Text(
            "Select an option",
            textAlign: TextAlign.center,
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  "Identify text",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    _option = true;
                  });
                  Navigator.pop(context);
                  _question("query");
                },
              ),
            ),
            SimpleDialogOption(
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  'Identify labels',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  setState(() {
                    _option = false;
                  });
                  Navigator.pop(context);
                  _question("query");
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _sendResponse(String _response) async {
    String myValue = await Settings().getString(
      'radiokey',
      'en',
    );

    if (await _flutterTts.isLanguageAvailable(myValue))
      await _flutterTts.setLanguage(myValue);

    String rsp;

    if (_response.isEmpty && _option && _image != null)
      rsp = await "I cannot identify any text in that image"
          .translate(to: myValue);
    else if (_response == "[]" && !_option)
      rsp = await "I cannot identify any object in that image"
          .translate(to: myValue);
    else {
      if (!_option && _image != null)
        rsp = await ("In this picture I can see: " +
                _response.substring(1, _response.length - 1).toLowerCase())
            .translate(to: myValue);
      else
        rsp = await _response.translate(to: myValue);
    }

    Message message = Message(
      text: rsp,
      name: "Alex",
      type: false,
      animationController: AnimationController(
        duration: Duration(milliseconds: 700),
        vsync: this,
      ),
    );

    _newVoiceText = message.text;

    setState(() {
      _messages.insert(0, message);
      _isAnswered = true;
    });

    message.animationController.forward();
    _speak();
  }

  void _response(query, bool welcomeMessage) async {
    if (_image != null) {
      if (_option) {
        _detectText(_image).then((onValue) {
          _image = null;
          _sendResponse(onValue);
        });
      } else {
        _detectLabels(_image).then((onValue) {
          _image = null;
          _sendResponse(onValue.toString());
        });
      }
    } else {
      _textController.clear();
      AIResponse _response = await Dialogflow(
        authGoogle: await AuthGoogle(
          fileJson: "assets/virtual-assistant-htiehx-78c19d0cb278.json",
        ).build(),
        language: Language.english,
      ).detectIntent(
        query,
      );
      if (welcomeMessage)
        _sendResponse(_response.getMessage());
      else {
        handleResponse(_response).then((onValue) {
          if (!onValue) _sendResponse(_response.getMessage());
        });
      }
    }
  }

  Future<bool> handleResponse(AIResponse response) async {
    switch (response.queryResult.action) {
      case "alarm.set":
        if (response.queryResult.parameters["time"].toString().isNotEmpty) {
          await AndroidIntent(
            action: 'android.intent.action.SET_ALARM',
            arguments: <String, dynamic>{
              'android.intent.extra.alarm.HOUR': int.parse(response
                  .queryResult.parameters["time"]
                  .toString()
                  .substring(11, 13)),
              'android.intent.extra.alarm.MINUTES': int.parse(response
                  .queryResult.parameters["time"]
                  .toString()
                  .substring(14, 16)),
              'android.intent.extra.alarm.MESSAGE':
                  response.queryResult.parameters["alarm-name"] ?? '',
              'android.intent.extra.alarm.SKIP_UI': true,
            },
          ).launch();
        } else
          return false;
        break;
      case "alarm.check":
        await AndroidIntent(
          action: 'android.intent.action.SHOW_ALARMS',
        ).launch();
        break;
      case "web.search":
        if (response.queryResult.parameters['q'].toString().isNotEmpty) {
          await AndroidIntent(
              action: 'android.intent.action.WEB_SEARCH',
              arguments: <String, dynamic>{
                'query': response.queryResult.parameters['q'],
              }).launch();
        } else
          return false;
        break;
      case "timer.set":
        if (response.queryResult.parameters['seconds'].toString().isNotEmpty) {
          await AndroidIntent(
              action: 'android.intent.action.SET_TIMER',
              arguments: <String, dynamic>{
                'android.intent.extra.alarm.LENGTH':
                    response.queryResult.parameters['seconds'],
                'android.intent.extra.alarm.SKIP_UI': true,
              }).launch();
        } else
          return false;
        break;
      case "camera.open":
        await AndroidIntent(
          action: 'android.media.action.STILL_IMAGE_CAMERA',
        ).launch();
        break;
      case "video.open":
        await AndroidIntent(
          action: 'android.media.action.VIDEO_CAMERA',
        ).launch();
        break;
      case "contact.insert":
        if (response.queryResult.parameters['phone-number']
                .toString()
                .isNotEmpty &&
            response.queryResult.parameters['given-name']
                .toString()
                .isNotEmpty) {
          await AndroidIntent(
            action: 'android.intent.action.INSERT',
            type: 'vnd.android.cursor.dir/contact',
            arguments: <String, dynamic>{
              'phone': response.queryResult.parameters['phone-number'],
              'name': response.queryResult.parameters['given-name'],
            },
          ).launch();
        } else
          return false;
        break;
      case "email.send":
        if (response.queryResult.parameters['email'].toString().isNotEmpty &&
            response.queryResult.parameters['text'].toString().isNotEmpty) {
          var url = 'mailto:' +
              response.queryResult.parameters['email'] +
              '?subject=' +
              response.queryResult.parameters['subject'] +
              '&body=' +
              response.queryResult.parameters['text'];

          if (await canLaunch(url)) await launch(url);
        } else
          return false;
        break;
      case "maps.search":
        if (response.queryResult.parameters['location'].toString().isNotEmpty) {
          await AndroidIntent(
            action: 'android.intent.action.VIEW',
            data: Uri.encodeFull(
              'geo:0,0?q=' +
                  response.queryResult.parameters['location']['city']
                      .toString(),
            ),
          ).launch();
        } else
          return false;
        break;
      case "call":
        if (response.queryResult.parameters['phone-number']
            .toString()
            .isNotEmpty) {
          var url = 'tel:' + response.queryResult.parameters['phone-number'];
          if (await canLaunch(url)) await launch(url);
        } else
          return false;
        break;
      case "settings":
        await AndroidIntent(action: 'android.settings.SETTINGS').launch();
        break;
      case "sms":
        if (response.queryResult.parameters['phone-number']
                .toString()
                .isNotEmpty &&
            response.queryResult.parameters['text'].toString().isNotEmpty) {
          var url = 'sms:' +
              response.queryResult.parameters['phone-number'] +
              '?body=' +
              response.queryResult.parameters['text'];
          if (await canLaunch(url)) await launch(url);
        } else
          return false;
        break;
      case "web_page":
        // AndroidIntent intent = AndroidIntent(
        //   action: 'android.intent.action.VIEW',
        //   data: Uri.parse("https:" + response.queryResult.parameters['url'])
        //       .toString(),
        // );
        // await intent.launch();
        //  closeWebView();
        // if (await canLaunch(url))
        //   await launch(
        //     url,
        //     // forceWebView: true,
        //     enableJavaScript: true,
        //   );
        //
        // flutterWebViewPlugin.launch(url);
        // flutterWebViewPlugin.close();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => new WebviewScaffold(
              url: "https://" + response.queryResult.parameters['url'],
              appBar: new AppBar(
                title: Text(
                  Localization.of(context).title,
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ),
        );
        break;
      case "application_details":
        await AndroidIntent(
          action: 'action_application_details_settings',
          data: 'package:vukan.com.virtualassistant',
        ).launch();
        break;
      case "navigation":
        if (response.queryResult.parameters['location'].toString().isNotEmpty) {
          await AndroidIntent(
            action: 'action_view',
            data: Uri.encodeFull(
              'google.navigation:q=' +
                  Uri.encodeFull(
                    response.queryResult.parameters['location']['city'],
                  ),
            ),
            package: 'com.google.android.apps.maps',
          ).launch();
        } else
          return false;
        break;
      default:
        return false;
    }
    _isAnswered = true;
    return true;
  }

  void _question(String text) async {
    try {
      var s = "";
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (text.trim().isNotEmpty) {
          if (_isAnswered) {
            Message message;
            if (_image != null) {
              message = Message(
                image: _image,
                name: widget.user.displayName,
                type: true,
                animationController: AnimationController(
                  duration: Duration(milliseconds: 700),
                  vsync: this,
                ),
                avatarImage: widget.user.photoUrl,
              );
            } else {
              _textController.clear();
              s = await text.translate(to: 'en');
              message = Message(
                  text: text,
                  name: widget.user.displayName,
                  type: true,
                  animationController: AnimationController(
                    duration: Duration(milliseconds: 700),
                    vsync: this,
                  ),
                  avatarImage: widget.user.photoUrl);
            }
            setState(() {
              _messages.insert(0, message);
              _isAnswered = false;
            });
            message.animationController.forward();
            _response(s, false);
          } else
            Utilities.showToast("Wait for the bot to respond first!");
        } else
          Utilities.showToast("You must enter the message first!");
      }
    } catch (_) {
      Utilities.showToast(
          "You must be connected to the internet to communicate with the assistant!");
    }
  }
}
