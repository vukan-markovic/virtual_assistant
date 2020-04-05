import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:virtual_assistant/languages.dart';
import 'package:virtual_assistant/localization.dart';
import 'package:virtual_assistant/login.dart';
import 'package:virtual_assistant/menuOption.dart';
import 'dart:io';
import 'package:virtual_assistant/message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences_settings/shared_preferences_settings.dart';
import 'package:virtual_assistant/speakLanguages.dart';

class Chatbot extends StatefulWidget {
  Chatbot({Key key, this.title, this.user}) : super(key: key);
  final String title;
  final FirebaseUser user;

  @override
  _ChatbotState createState() => new _ChatbotState();
}

enum TtsState { playing, stopped }

class _ChatbotState extends State<Chatbot> with TickerProviderStateMixin {
  bool isPressed = false;
  bool isLoading;
  final List<ChatMessage> _messages = <ChatMessage>[];
  final translator = new GoogleTranslator();
  final TextEditingController _textController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Choice _selectedChoice = choices[0];
  bool flag = true;
  String language = "en";
  File _image;
  FlutterTts flutterTts;
  String imageLabels;
  double volume = 0.5;
  bool _camera = false;
  double pitch = 1.0;
  double rate = 0.5;
  String newVoiceText;
  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  bool _hasSpeech = false;
  double level = 0.0;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();
  Map<String, String> speakLanguages = {};
  ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
  TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();

  @override
  initState() {
    super.initState();
    initTts();
    initSpeechState();
    response("hi there");
  }

  Route _createRoute(StatefulWidget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      _localeNames = await speech.locales();
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
      for (var item in _localeNames) {
        speakLanguages[item.localeId] = item.name;
      }
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  void startListening() async {
    Fluttertoast.showToast(
        msg: "Start",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    lastWords = "";
    lastError = "";

    _currentLocaleId = await Settings().getString(
      'radiokeyspeak',
      'en',
    );

    speech.listen(
      onResult: resultListener
      // listenFor: Duration(seconds: 2),
      ,
      localeId: _currentLocaleId,
      // onSoundLevelChange: soundLevelListener,
      // cancelOnError: true,
      // partialResults: true
    );
    setState(() {});
  }

  void stopListening() {
    Fluttertoast.showToast(
        msg: "Stop",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    speech.stop();
    setState(() {
      // level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      if (result.recognizedWords.isNotEmpty) {
        Fluttertoast.showToast(
            msg: result.recognizedWords,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }

      if (!speech.isListening && lastWords != result.recognizedWords) {
        lastWords = result.recognizedWords;
        handleSubmitted(result.recognizedWords);
        isPressed = false;
      }
    });
  }

  void soundLevelListener(double level) {
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    // changeStatusForStress(status);
    setState(() {
      lastStatus = "$status";
    });
  }

  initTts() {
    flutterTts = FlutterTts();

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });
  }

  Future speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (newVoiceText != null) {
      if (newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(newVoiceText);
        if (result == 1) setState(() => ttsState = TtsState.playing);
      }
    }
  }

  @override
  void dispose() {
    labeler.close();
    textRecognizer.close();
    for (ChatMessage message in _messages)
      message.animationController.dispose();
    super.dispose();
    flutterTts.stop();
  }

  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
      if (_selectedChoice.title == "Sign out")
        _signOut();
      else if (_selectedChoice.title == "Assistant language")
        Navigator.of(context).push(_createRoute(Languages(language: language)));
      else if (_selectedChoice.title == "Your speach language") {
        Navigator.of(context).push(_createRoute(
          SpeachLanguages(
            language: language,
            speakLanguages: speakLanguages,
          ),
        ));
      } else if (_selectedChoice.title == "Delete account") {
        _auth.currentUser().then((onValue) => () {
              onValue.delete();
              Navigator.of(context).push(_createRoute(SignInPage()));
            });
      }
    });
  }

  // If you receive compilation errors, try an earlier version of ML Kit: Image Labeling.

  Future<List<String>> detectLabels(File image) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final List<ImageLabel> labels = await labeler.processImage(visionImage);
    List<String> texts = [];
    for (ImageLabel label in labels) {
      texts.add(label.text);
    }

    return texts;
  }

  Future<String> detectText(File image) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    return visionText.text;
  }

  // Image.file(_image)

  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _image = image;
        isLoading = true;

        handleSubmitted("text");
      });
    }
  }

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
        _camera = true;
        isLoading = true;
        handleSubmitted("query");
      });
    }
  }

  void _signOut() async {
    await _auth.signOut();
    _pushPage(context, SignInPage());
  }

  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onSubmitted: handleSubmitted,
                decoration: new InputDecoration.collapsed(
                    hintStyle: TextStyle(color: Colors.red),
                    hintText: "Send a message" /*, border: InputBorder.none*/),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(
                    Icons.send, /*color: Colors.blue,*/
                  ),
                  onPressed: () => handleSubmitted(_textController.text)),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.mic,
                      color: (isPressed) ? Colors.red : Colors.redAccent),
                  // tooltip: "",
                  onPressed: _hasSpeech && !speech.isListening
                      ? startListening
                      : stopListening),
            ),
          ],
        ),
      ),
    );
  }

  void response(query) async {
    String myValue = await Settings().getString(
      'radiokey',
      'en',
    );
    if (await flutterTts.isLanguageAvailable(myValue))
      await flutterTts.setLanguage(myValue);
    ChatMessage message;

    if (_image != null) {
      if (_camera) {
        detectText(_image).then((onValue) {
          message = new ChatMessage(
            text: onValue.toString(),
            name: "Alex",
            type: false,
            animationController: new AnimationController(
              duration: new Duration(milliseconds: 700),
              vsync: this,
            ),
          );
          newVoiceText = message.text;
          setState(() {
            _messages.insert(0, message);
            flag = true;
            speak();
          });
          message.animationController.forward();
        });
      } else {
        detectLabels(_image).then((onValue) {
          message = new ChatMessage(
            text: onValue.toString(),
            name: "Alex",
            type: false,
            animationController: new AnimationController(
              duration: new Duration(milliseconds: 700),
              vsync: this,
            ),
          );
          newVoiceText = message.text;
          setState(() {
            _messages.insert(0, message);
            flag = true;
            speak();
          });
          message.animationController.forward();
        });
      }
    } else {
      _textController.clear();
      AuthGoogle authGoogle = await AuthGoogle(
              fileJson: "assets/virtual-assistant-htiehx-78c19d0cb278.json")
          .build();
      Dialogflow dialogflow =
          Dialogflow(authGoogle: authGoogle, language: Language.english);
      AIResponse response = await dialogflow.detectIntent(query);
      String rsp = await response.getMessage().translate(to: myValue);

      message = new ChatMessage(
        text: rsp ?? "What?",
        // new TypeMessage(response.getListMessage()[0]).platform,
        name: "Alex",
        type: false,
        animationController: new AnimationController(
          duration: new Duration(milliseconds: 700),
          vsync: this,
        ),
      );

      newVoiceText = message.text;
      setState(() {
        _messages.insert(0, message);
        flag = true;
        speak();
      });
      message.animationController.forward();
    }
  }

  void handleSubmitted(String text) async {
    // try {
    var s = "";
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      if (text.trim().isNotEmpty) {
        if (flag) {
          ChatMessage message;
          if (_image != null) {
            message = new ChatMessage(
                image: _image,
                name: widget.user.displayName,
                type: true,
                animationController: new AnimationController(
                  duration: new Duration(milliseconds: 700),
                  vsync: this,
                ),
                photo: widget.user.photoUrl);
          } else {
            _textController.clear();
            s = await text.translate(to: 'en');
            message = new ChatMessage(
                text: text,
                name: widget.user.displayName,
                type: true,
                animationController: new AnimationController(
                  duration: new Duration(milliseconds: 700),
                  vsync: this,
                ),
                photo: widget.user.photoUrl);
          }
          setState(() {
            _messages.insert(0, message);
            flag = false;
          });
          message.animationController.forward();
          response(s);
        } else {
          Fluttertoast.showToast(
              msg: "Wait for the bot to respond first!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      } else {
        Fluttertoast.showToast(
            msg: "You must enter the message first!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
    // } catch () {
    //   Fluttertoast.showToast(
    //       msg:
    //           "You must be connected to the internet to communicate with the assistant!",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.CENTER,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //       fontSize: 16.0);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //backgroundColor: Color(0xf4f4f4f4f4),
      appBar: new AppBar(
        title: new Text(DemoLocalizations.of(context).title),
        // leading: IconButton(
        //   icon: Icon(Icons.menu),
        //   tooltip: 'Navigation menu',
        //   onPressed: null,
        // ),
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
          IconButton(
              icon: Icon(Icons.add_a_photo),
              onPressed: () => getImageGallery()),
          IconButton(
              icon: Icon(Icons.camera), onPressed: () => getImageCamera())
        ],
        //backgroundColor: Colors.blue,
      ),
      body: new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
          padding: new EdgeInsets.all(8.0),
          reverse: true,
          itemBuilder: (_, int index) => _messages[index],
          itemCount: _messages.length,
        )),
        new Divider(height: 1.0),
        new Container(
          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
          child: _buildTextComposer(),
        ),
      ]),
    );
  }
}
