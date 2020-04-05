import 'dart:io';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:virtual_assistant/menuOption.dart';
import 'package:share/share.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(
      {this.text,
      this.name,
      this.type,
      this.photo,
      this.animationController,
      this.image});

  final AnimationController animationController;
  final String text;
  final String name;
  final bool type;
  final String photo;
  final File image;

  List<Widget> otherMessage(context) {
    return <Widget>[
      new Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: new CircleAvatar(
          child: new Image.asset("img/ic_launcher.png"),
          // backgroundColor: Colors.transparent
        ),
      ),
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(this.name,
                style: new TextStyle(fontWeight: FontWeight.bold)),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Padding(
                padding: EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                child: GestureDetector(
                  child: new Text(
                    text,
                    style: TextStyle(color: Colors.black),
                  ),
                  onLongPress: () {
                    PopupMenuButton<Choice>(
                      onSelected: share(),
                      itemBuilder: (BuildContext context) {
                        return const <Choice>[
                          const Choice(title: 'Share', icon: Icons.share)
                        ].map((Choice choice) {
                          return PopupMenuItem<Choice>(
                            value: choice,
                            child: Text(choice.title),
                          );
                        }).toList();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  share() {
    Share.share(text);
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text(this.name, style: Theme.of(context).textTheme.subhead),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Padding(
                padding: EdgeInsets.only(
                    top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                child: image != null
                    ? Image.file(image)
                    : new Text(
                        text,
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
      new Container(
        margin: const EdgeInsets.only(left: 16.0),
        child:
            // ClipRRect(borderRadius: BorderRadius.circular(15.0),child: ,clipBehavior: Clip.hardEdge,
            new CircleAvatar(
                child: new FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage, image: this.photo)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      axisAlignment: 0.0,
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.easeOut),
      child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: this.type ? myMessage(context) : otherMessage(context),
          )),
    );
  }
}
