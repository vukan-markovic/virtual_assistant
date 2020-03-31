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

class _ChatbotState extends State<Chatbot> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final translator = new GoogleTranslator();
  final TextEditingController _textController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Choice _selectedChoice = choices[0];
  bool flag = true;
  String language = "en";
  File _image;
  FlutterTts flutterTts;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  String newVoiceText;
  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  bool _hasSpeech = false;
  bool _stressTest = false;
  double level = 0.0;
  int _stressLoops = 0;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();
  Map<String, String> speakLanguages = {};
  // languages.first;

  // void onCurrentLocale(String locale) {
  //   setState(
  //       () => selectedLang = languages.firstWhere((l) => l.code == locale));
  // }

  @override
  initState() {
    super.initState();
    initTts();
    initSpeechState();
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

    print(_currentLocaleId);

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
    print("POZVANOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
    setState(() {
      Fluttertoast.showToast(
          msg: result.recognizedWords,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      if (!speech.isListening && lastWords != result.recognizedWords) {
        lastWords = result.recognizedWords;
        handleSubmitted(result.recognizedWords);
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

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
      if (_selectedChoice.title == "Sign out")
        _signOut();
      else if (_selectedChoice.title == "Languages")
        Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: (_) => Languages(language: language)),
        );
      else if (_selectedChoice.title == "Speach languages") {
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => SpeachLanguages(
            language: language,
            speakLanguages: speakLanguages,
          ),
        ));
      }
    });
  }

  Future<List<String>> detectLabels(File image) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    final List<ImageLabel> labels = await labeler.processImage(visionImage);
    List<String> texts;
    for (ImageLabel label in labels) {
      texts.add(label.text);
    }
    labeler.close();
    return texts;
  }

  // void detectText(File image) async {
  //   final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
  //   final TextRecognizer textRecognizer =
  //       FirebaseVision.instance.textRecognizer();
  //   final VisionText visionText =
  //       await textRecognizer.processImage(visionImage);

  //   String text = visionText.text;

  //   for (TextBlock block in visionText.blocks) {
  //     final String text = block.text;
  //     final List<RecognizedLanguage> languages = block.recognizedLanguages;
  //   }

  //   textRecognizer.close();
  // }

  Future getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  Future getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
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
                decoration:
                    new InputDecoration.collapsed(hintText: "Send a message"),
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
                  icon: new Icon(
                    Icons.mic, /*color: Colors.blue,*/
                  ),
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
    _textController.clear();
    AuthGoogle authGoogle = await AuthGoogle(
            fileJson: "assets/virtual-assistant-htiehx-78c19d0cb278.json")
        .build();
    Dialogflow dialogflow =
        Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse response = await dialogflow.detectIntent(query);

    String myValue = await Settings().getString(
      'radiokey',
      'en',
    );
    assert(myValue.isNotEmpty);
    String rsp = await response.getMessage().translate(to: myValue);

    ChatMessage message = new ChatMessage(
      text: rsp ?? "What?",
      // new TypeMessage(response.getListMessage()[0]).platform,
      name: "Alex",
      type: false,
    );

    if (await flutterTts.isLanguageAvailable(myValue))
      await flutterTts.setLanguage(myValue);

    newVoiceText = message.text;
    setState(() {
      _messages.insert(0, message);
      flag = true;
      speak();
    });
  }

  void handleSubmitted(String text) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (text.isNotEmpty) {
          if (flag) {
            _textController.clear();

            var s = await text.translate(to: 'en');

            ChatMessage message = new ChatMessage(
                text: text,
                name: widget.user.displayName,
                type: true,
                photo: widget.user.photoUrl);

            setState(() {
              _messages.insert(0, message);
              flag = false;
            });
            response(s);
          } else {
            // Fluttertoast.showToast(
            //     msg: "Wait for the bot to respond first!",
            //     toastLength: Toast.LENGTH_SHORT,
            //     gravity: ToastGravity.CENTER,
            //     timeInSecForIosWeb: 1,
            //     backgroundColor: Colors.red,
            //     textColor: Colors.white,
            //     fontSize: 16.0);
          }
        } else {
          // Fluttertoast.showToast(
          //     msg: "You must enter the message first!",
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.CENTER,
          //     timeInSecForIosWeb: 1,
          //     backgroundColor: Colors.red,
          //     textColor: Colors.white,
          //     fontSize: 16.0);
        }
      }
    } catch (_) {
      Fluttertoast.showToast(
          msg:
              "You must be connected to the internet to communicate with the assistant!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //backgroundColor: Color(0xf4f4f4f4f4),
      appBar: new AppBar(
        title: new Text("Virtual assistant"),
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
