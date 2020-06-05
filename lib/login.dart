import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:virtual_assistant/chatbot.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:virtual_assistant/credentials.dart';
import 'package:virtual_assistant/utilities.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  FirebaseUser _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SafeArea(
        child: Builder(builder: (BuildContext context) {
          return Center(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              scrollDirection: Axis.vertical,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        'Sign in to chat with assistant',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      alignment: Alignment.center,
                      child: RaisedButton.icon(
                        color: Theme.of(context).accentColor,
                        onPressed: () async {
                          _signInWithGoogle();
                        },
                        icon: Image.asset(
                          "img/google.png",
                          width: 30,
                          height: 30,
                        ),
                        label: Text(
                          'Sign in with Google',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      alignment: Alignment.center,
                      child: RaisedButton.icon(
                        color: Theme.of(context).accentColor,
                        onPressed: () async {
                          _signInWithTwitter();
                        },
                        icon: Image.asset(
                          "img/twitter.png",
                          width: 30,
                          height: 30,
                        ),
                        label: Text(
                          'Sign in with Twitter',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      alignment: Alignment.center,
                      child: RaisedButton.icon(
                        color: Theme.of(context).accentColor,
                        onPressed: () async {
                          _signInWithFacebook();
                        },
                        icon: Image.asset(
                          "img/facebook.png",
                          width: 30,
                          height: 30,
                        ),
                        label: Text(
                          'Sign in with Facebook',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  void _signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      _user = (await _auth.signInWithCredential(credential)).user;
    } catch (_) {}
    if (_user != null) {
      Utilities.showToast("Successfully signed in!");
      Utilities.pushPage(context, Chatbot(user: _user));
    } else
      Utilities.showToast("Sign in failed!");
  }

  void _signInWithFacebook() async {
    try {
      final result = await FacebookLogin().logIn(['email']);
      _user = (await _auth.signInWithCredential(
        FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token),
      ))
          .user;
    } catch (_) {}
    if (_user != null) {
      Utilities.showToast("Successfully signed in!");
      Utilities.pushPage(context, Chatbot(user: _user));
    } else
      Utilities.showToast("Sign in failed!");
  }

  void _signInWithTwitter() async {
    try {
      final TwitterLoginResult result = await TwitterLogin(
        consumerKey: Credentials.twitter_consumerKey,
        consumerSecret: Credentials.twitter_consumerSecret,
      ).authorize();
      _user = (await _auth.signInWithCredential(
              TwitterAuthProvider.getCredential(
                  authToken: result.session.token,
                  authTokenSecret: result.session.secret)))
          .user;
    } catch (_) {}
    if (_user != null) {
      Utilities.showToast("Successfully signed in!");
      Utilities.pushPage(context, Chatbot(user: _user));
    } else
      Utilities.showToast("Sign in failed!");
  }
}
