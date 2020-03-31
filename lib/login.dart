import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:virtual_assistant/chatbot.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class SignInPage extends StatefulWidget {
  final String title = 'Login';

  @override
  State<StatefulWidget> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Builder(builder: (BuildContext context) {
        return Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20.0),
            scrollDirection: Axis.vertical,
            children: <Widget>[_SignInSection()],
          ),
        );
      }),
      backgroundColor: Colors.redAccent,
    );
  }
}

class _SignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignInSectionState();
}

class _SignInSectionState extends State<_SignInSection> {
  bool _success;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: const Text('Sign in to chat with assistant'),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton.icon(
            onPressed: () async {
              _signInWithGoogle();
            },
            icon: Image.asset(
              "img/google.png",
              width: 30,
              height: 30,
            ),
            label: const Text('Sign in with Google'),
            color: Colors.red,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton.icon(
            onPressed: () async {
              _signInWithTwitter();
            },
            icon: Image.asset(
              "img/twitter.png",
              width: 30,
              height: 30,
            ),
            label: const Text('Sign in with Twitter'),
            color: Colors.red,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child: RaisedButton.icon(
            onPressed: () async {
              _signInWithFacebook();
            },
            icon: Image.asset(
              "img/facebook.png",
              width: 30,
              height: 30,
            ),
            label: const Text('Sign in with Facebook'),
            color: Colors.red,
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _success == null
                ? ''
                : (_success ? 'Successfully signed in!' : 'Sign in failed!'),
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  void _signInWithGoogle() async {
    FirebaseUser user;

    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      user = (await _auth.signInWithCredential(credential)).user;
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
    } catch (_) {}
    setState(() {
      if (user != null) {
        _success = true;
        _pushPage(context, Chatbot(user: user));
      } else {
        _success = false;
      }
    });
  }

  void _signInWithFacebook() async {
    FirebaseUser user;

    try {
      final facebookLogin = FacebookLogin();
      final result = await facebookLogin.logIn(['email']);

      final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token);
      FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
    } catch (_) {}
    setState(() {
      if (user != null) {
        _success = true;
        _pushPage(context, Chatbot(user: user));
      } else
        _success = false;
    });
  }

  void _signInWithTwitter() async {
    FirebaseUser user;

    try {
      var twitterLogin = new TwitterLogin(
        consumerKey: '44mkQlM6NuSJLteObmHosVior',
        consumerSecret: 'YSAGPCXOKTQm333pxKBlr98AvX3hDtD2cGHoLpnfZZb6ZUrSQf',
      );

      final TwitterLoginResult result = await twitterLogin.authorize();
      final AuthCredential credential = TwitterAuthProvider.getCredential(
          authToken: result.session.token,
          authTokenSecret: result.session.secret);
      user = (await _auth.signInWithCredential(credential)).user;
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
    } catch (_) {}
    setState(() {
      if (user != null) {
        _success = true;
        _pushPage(context, Chatbot(user: user));
      } else
        _success = false;
    });
  }

  void _pushPage(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}
