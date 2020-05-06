import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtual_assistant/credits.dart';
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
  ChatbotState createState() => ChatbotState();
}

enum TtsState { playing, stopped }

class ChatbotState extends State<Chatbot> with TickerProviderStateMixin {
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
      'Privacy Policy',
      'Terms & Conditions',
      'Credits',
      'Sign out',
      'Delete account',
    ];
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

  void _select(String menuOption) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (menuOption) {
      case "Sign out":
        _signOut();
        break;
      case "Assistant language":
        if (prefs.getInt('language') == null || prefs.getInt('language') == 0)
          dialog(
              context,
              "For a lifetime access to assistant language setup, watch the ad",
              "I accept",
              "Cancel");
        else
          Navigator.of(context).push(Utilities.createRoute(Languages()));
        break;
      case "Your speach language":
        if (prefs.getInt('speech') == null || prefs.getInt('speech') == 0)
          dialog(
              context,
              "For a lifetime access to speach language setup, watch the ad",
              "I accept",
              "Cancel");
        else
          Navigator.of(context).push(Utilities.createRoute(
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
        dialog(context, "Are you sure?", "Yes", "No");
        break;
      case "Privacy Policy":
        Utilities.pushWebPage(context,
            "https://sites.google.com/view/virtual-assistantprivacypolicy");
        break;
      case "Terms & Conditions":
        Utilities.pushWebPage(context,
            "https://sites.google.com/view/virtualassistanttermscondition");
        break;
      case "Credits":
        Navigator.of(context).push(Utilities.createRoute(
          Credits(),
        ));
        break;
    }
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
    if (visionText.text == null || visionText.text.trim().isEmpty) return "[]";
    return visionText.text;
  }

  Future _getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _image = image;
      });
      dialog(context, "Select an option", "Identify text", "Identify labels");
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

  void _sendResponse(String _response) async {
    String myValue = await Settings().getString(
      'radiokey',
      'en',
    );

    if (await _flutterTts.isLanguageAvailable(myValue))
      await _flutterTts.setLanguage(myValue);

    String rsp;
    print(_response);
    if (_response == "[]" && _image != null) {
      if (_option)
        rsp = await "I cannot identify any text in that image"
            .translate(to: myValue);
      else
        rsp = await "I cannot identify any object in that image"
            .translate(to: myValue);
    } else {
      if (!_option && _image != null)
        rsp = await ("In this picture I can see: " +
                _response.substring(1, _response.length - 1).toLowerCase())
            .translate(to: myValue);
      else
        rsp = await _response.translate(to: myValue);
    }

    _image = null;

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
          _sendResponse(onValue);
        });
      } else {
        _detectLabels(_image).then((onValue) {
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

  void launchIntent(AndroidIntent intent) {
    intent.canResolveActivity().then((onValue) {
      if (onValue)
        intent.launch();
      else
        _response("intentFail", false);
    });
  }

  Future<bool> handleResponse(AIResponse response) async {
    switch (response.queryResult.action) {
      case "alarm.set":
        if (response.queryResult.parameters["time"].toString().isNotEmpty) {
          launchIntent(AndroidIntent(
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
          ));
        } else
          return false;
        break;
      case "alarm.check":
        launchIntent(AndroidIntent(
          action: 'android.intent.action.SHOW_ALARMS',
        ));
        break;
      case "web.search":
        if (response.queryResult.parameters['q'].toString().isNotEmpty) {
          launchIntent(AndroidIntent(
              action: 'android.intent.action.WEB_SEARCH',
              arguments: <String, dynamic>{
                'query': response.queryResult.parameters['q'],
              }));
        } else
          return false;
        break;
      case "timer.set":
        if (response.queryResult.parameters['seconds'].toString().isNotEmpty) {
          launchIntent(AndroidIntent(
              action: 'android.intent.action.SET_TIMER',
              arguments: <String, dynamic>{
                'android.intent.extra.alarm.LENGTH':
                    response.queryResult.parameters['seconds'],
                'android.intent.extra.alarm.SKIP_UI': true,
              }));
        } else
          return false;
        break;
      case "camera.open":
        launchIntent(AndroidIntent(
          action: 'android.media.action.STILL_IMAGE_CAMERA',
        ));
        break;
      case "video.open":
        launchIntent(AndroidIntent(
          action: 'android.media.action.VIDEO_CAMERA',
        ));
        break;
      case "contact.insert":
        if (response.queryResult.parameters['phone-number']
                .toString()
                .isNotEmpty &&
            response.queryResult.parameters['given-name']
                .toString()
                .isNotEmpty) {
          launchIntent(AndroidIntent(
            action: 'android.intent.action.INSERT',
            type: 'vnd.android.cursor.dir/contact',
            arguments: <String, dynamic>{
              'phone': response.queryResult.parameters['phone-number'],
              'name': response.queryResult.parameters['given-name'],
            },
          ));
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

          if (await canLaunch(url))
            await launch(url);
          else
            _response("intentFail", false);
        } else
          return false;
        break;
      case "maps.search":
        if (response.queryResult.parameters['location'].toString().isNotEmpty) {
          launchIntent(AndroidIntent(
            action: 'android.intent.action.VIEW',
            data: Uri.encodeFull(
              'geo:0,0?q=' +
                  response.queryResult.parameters['location']['city']
                      .toString(),
            ),
          ));
        } else
          return false;
        break;
      case "call":
        if (response.queryResult.parameters['phone-number']
                .toString()
                .isNotEmpty &&
            await Permission.phone.request().isGranted) {
          launchIntent(AndroidIntent(
            action: 'android.intent.action.CALL',
            data: Uri.parse(
                    'tel:' + response.queryResult.parameters['phone-number'])
                .toString(),
          ));
        } else
          return false;
        break;
      case "settings":
        launchIntent(AndroidIntent(action: 'android.settings.SETTINGS'));
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
          if (await canLaunch(url))
            await launch(url);
          else
            _response("intentFail", false);
        } else
          return false;
        break;
      case "web_page":
        Utilities.pushWebPage(
            context, "https://" + response.queryResult.parameters['url']);
        break;
      case "application_details":
        launchIntent(AndroidIntent(
          action: 'action_application_details_settings',
          data: 'package:vukan.com.virtual_assistant',
        ));
        break;
      case "navigation":
        if (response.queryResult.parameters['location'].toString().isNotEmpty) {
          launchIntent(AndroidIntent(
            action: 'action_view',
            data: Uri.encodeFull(
              'google.navigation:q=' +
                  Uri.encodeFull(
                    response.queryResult.parameters['location']['city'],
                  ),
            ),
            package: 'com.google.android.apps.maps',
          ));
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
    var s = "";

    Utilities.isConnected().then((onValue) async {
      if (onValue) {
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
              if (s == null || s.isEmpty) s = 'qqqq';
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
      } else
        Utilities.showToast(
            "You must be connected to the internet to communicate with the assistant!");
    });
  }

  Future<void> dialog(BuildContext context, String title, String option1,
      String option2) async {
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
            title,
            textAlign: TextAlign.center,
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  option1,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (title == "Select an option") {
                    setState(() {
                      _option = true;
                    });
                    _question("query");
                  } else if (title == "Are you sure?") {
                    Utilities.isConnected().then((onValue) {
                      if (onValue) {
                        widget.user.delete();
                        Utilities.showToast("Account is deleted!");
                        Utilities.pushPage(context, Login());
                      } else
                        Utilities.showToast(
                            "You must be connected to the internet to delete account!");
                    });
                  } else if (title ==
                      "For a lifetime access to assistant language setup, watch the ad")
                    Utilities.isConnected().then((onValue) {
                      if (onValue)
                        Navigator.of(context)
                            .push(Utilities.createRoute(Languages()));
                      else
                        Utilities.showToast(
                            "You must be connected to the internet!");
                    });
                  else
                    Utilities.isConnected().then((onValue) {
                      if (onValue)
                        Navigator.of(context).push(Utilities.createRoute(
                          SpeechLanguages(
                            speechLanguages: _speechLanguages,
                          ),
                        ));
                      else
                        Utilities.showToast(
                            "You must be connected to the internet!");
                    });
                },
              ),
            ),
            SimpleDialogOption(
              child: RaisedButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  option2,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (title == "Select an option") {
                    setState(() {
                      _option = false;
                    });
                    _question("query");
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
