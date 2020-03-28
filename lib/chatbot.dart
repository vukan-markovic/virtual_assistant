import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_mlkit_language/firebase_mlkit_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:virtual_assistant/login.dart';
import 'package:virtual_assistant/menuOption.dart';
import 'dart:io';
import 'package:virtual_assistant/message.dart';
import 'package:image_picker/image_picker.dart';

class HomePageDialogflowV2 extends StatefulWidget {
  HomePageDialogflowV2({Key key, this.title, this.user}) : super(key: key);
  final String title;
  final FirebaseUser user;

  @override
  _HomePageDialogflowV2 createState() => new _HomePageDialogflowV2();
}

class _HomePageDialogflowV2 extends State<HomePageDialogflowV2> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Choice _selectedChoice = choices[0];
  bool flag = true;
  File _image;

  void _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
      if (_selectedChoice.title == "Sign out") _signOut();
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

  void detectText(File image) async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    String text = visionText.text;
  
    for (TextBlock block in visionText.blocks) {
      final String text = block.text;
      final List<RecognizedLanguage> languages = block.recognizedLanguages;
    }

    textRecognizer.close();
  }

  Future<String> identifyLanguage(String message) async {
    final LanguageIdentifier languageIdentifier =
        FirebaseLanguage.instance.languageIdentifier();
    final List<LanguageLabel> labels =
        await languageIdentifier.processText(message);
    return labels[0].languageCode;
  }

  Future<String> translateMessage(
      String message, String fromLanguage, String toLanguage) async {
    final ModelManager modelManager = FirebaseLanguage.instance.modelManager();
    modelManager.downloadModel(fromLanguage);
    final LanguageTranslator languageTranslator =
        FirebaseLanguage.instance.languageTranslator(fromLanguage, toLanguage);
    final String translatedString =
        await languageTranslator.processText(message);
    return translatedString;
  }

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
                onSubmitted: _handleSubmitted,
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
                  onPressed: () => _handleSubmitted(_textController.text)),
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
    ChatMessage message = new ChatMessage(
      text: response.getMessage() ??
          new TypeMessage(response.getListMessage()[0]).platform,
      name: "Alex",
      type: false,
    );
    setState(() {
      _messages.insert(0, message);
      flag = true;
    });
  }

  void _handleSubmitted(String text) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (text.isNotEmpty) {
          if (flag) {
            _textController.clear();

            ChatMessage message = new ChatMessage(
                text: text,
                name: widget.user.displayName,
                type: true,
                photo: widget.user.photoUrl);

            setState(() {
              _messages.insert(0, message);
              flag = false;
            });

            response(text);
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
    } on SocketException catch (_) {
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
