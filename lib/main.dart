import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'dart:io';
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool _isRecording = false;
  bool _isPlaying = false;
  StreamSubscription _recorderSubscription;
  StreamSubscription _playerSubscription;
  FlutterSound flutterSound;

  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';

  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setSubscriptionDuration(0.01);
  }

  void startRecorder() async{
    try {
      String path = await flutterSound.startRecorder(null);
      print('startRecorder: $path');

      _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        String txt = DateFormat('mm:ss:SS', 'en_US').format(date);

        this.setState(() {
          this._recorderTxt = txt.substring(0, 8);
        });
      });

      this.setState(() {
        this._isRecording = true;
      });
    } catch (err) {
      print('startRecorder error: $err');
    }
  }

  void stopRecorder() async{
    try {
      String result = await flutterSound.stopRecorder();
      print('stopRecorder: $result');

      if (_recorderSubscription != null) {
        _recorderSubscription.cancel();
        _recorderSubscription = null;
      }

      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  void startPlayer() async{
    String path = await flutterSound.startPlayer(null);
    await flutterSound.setVolume(1.0);
    print('startPlayer: $path');

    try {
      _playerSubscription = flutterSound.onPlayerStateChanged.listen((e) {
        if (e != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
          String txt = DateFormat('mm:ss:SS', 'en_US').format(date);
          this.setState(() {
            this._isPlaying = true;
            this._playerTxt = txt.substring(0, 8);
          });
        }
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void stopPlayer() async{
    try {
      String result = await flutterSound.stopPlayer();
      print('stopPlayer: $result');
      if (_playerSubscription != null) {
        _playerSubscription.cancel();
        _playerSubscription = null;
      }

      this.setState(() {
        this._isPlaying = false;
      });
    } catch (err) {
      print('error: $err');
    }
  }

  void pausePlayer() async{
    String result = await flutterSound.pausePlayer();
    print('pausePlayer: $result');
  }

  void resumePlayer() async{
    String result = await flutterSound.resumePlayer();
    print('resumePlayer: $result');
  }

  void seekToPlayer(int milliSecs) async{
    int secs = Platform.isIOS ? milliSecs / 1000 : milliSecs;

    String result = await flutterSound.seekToPlayer(secs);
    print('seekToPlayer: $result');
  }

  String randomQuestion() {
    var questions = ["Tell me about yourself.", "How did you find out about this position?", "Why do you want to work in this company?", "Tell me about an accomplishment you are most proud of.", " Where do you see yourself in five years?", "What can you offer us that someone else can not?", "Tell me about a time you made a mistake.", "What was your biggest failure?", "How do you handle pressure?", "What gets you up in the morning?", "Are you a leader or a follower?", "What are your hobbies?", "What makes you uncomfortable?", "What are some of your leadership experiences?" , "What do you like the most and least about working in this industry?", "What motivates you?", "Who’s your mentor?", "Why should we hire you?", "What are your greatest professional strengths?", "What do you consider to be your weaknesses?", " Tell me about a challenge or conflict you've faced at work, and how you dealt with it.", "What's your dream job?", "Why are you leaving your current job?", "What's a time you disagreed with a decision that was made at work?", "If you were an animal, which one would you want to be?", "Do you have any questions for us?"];
    var randomQuestions = (questions..shuffle()).first;
    return randomQuestions;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Interview Me'),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(32.0),
              child: Text(randomQuestion(),
                softWrap: true,
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                )
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 24.0, bottom:16.0),
                  child: Text(
                    this._recorderTxt,
                    style: TextStyle(
                      fontSize: 48.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 56.0,
                  height: 56.0,
                  child: ClipOval(
                    child: FlatButton(
                      onPressed: () {
                        if (!this._isRecording) {
                          return this.startRecorder();
                        }
                        this.stopRecorder();
                      },
                      padding: EdgeInsets.all(8.0),
                      child: Image(
                        image: this._isRecording ? AssetImage('res/icons/ic_stop.png') : AssetImage('res/icons/ic_mic.png'),
                      ),
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 60.0, bottom:16.0),
                  child: Text(
                    this._playerTxt,
                    style: TextStyle(
                      fontSize: 48.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 56.0,
                  height: 56.0,
                  child: ClipOval(
                    child: FlatButton(
                      onPressed: () {
                        startPlayer();
                      },
                      padding: EdgeInsets.all(8.0),
                      child: Image(
                        image: AssetImage('res/icons/ic_play.png'),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 56.0,
                  height: 56.0,
                  child: ClipOval(
                    child: FlatButton(
                      onPressed: () {
                        pausePlayer();
                      },
                      padding: EdgeInsets.all(8.0),
                      child: Image(
                        width: 36.0,
                        height: 36.0,
                        image: AssetImage('res/icons/ic_pause.png'),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 56.0,
                  height: 56.0,
                  child: ClipOval(
                    child: FlatButton(
                      onPressed: () {
                        stopPlayer();
                      },
                      padding: EdgeInsets.all(8.0),
                      child: Image(
                        width: 28.0,
                        height: 28.0,
                        image: AssetImage('res/icons/ic_stop.png'),
                      ),
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            FloatingActionButton(
              onPressed: main,
              child: new Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }
}