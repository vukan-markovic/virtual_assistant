import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class Message extends StatelessWidget {
  Message({
    this.text,
    this.name,
    this.type,
    this.avatarImage,
    this.image,
    this.animationController,
  });

  final String text;
  final String name;
  final bool type;
  final String avatarImage;
  final File image;
  final AnimationController animationController;

  List<Widget> _otherMessage(context) {
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(
          child: Image.asset("img/ic_launcher.png"),
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              this.name,
            ),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment(0.1, 0.0),
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).accentColor,
                    ]),
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                child: GestureDetector(
                  child: Text(
                    text,
                    style: TextStyle(color: Colors.white),
                  ),
                  onLongPress: () => Share.share(text),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _myMessage(context) {
    return <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              this.name,
            ),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.1, 0.0),
                    colors: [
                      Theme.of(context).accentColor,
                      Theme.of(context).primaryColor,
                    ]),
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                child: image != null
                    ? Image.file(image)
                    : Text(
                        text,
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
          radius: 22.0,
          backgroundImage: NetworkImage(
            this.avatarImage,
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axisAlignment: 0.0,
      sizeFactor: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: this.type ? _myMessage(context) : _otherMessage(context),
        ),
      ),
    );
  }
}
