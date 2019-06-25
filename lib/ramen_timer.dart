import 'package:flutter/material.dart';
import 'dart:async';

class RamenTimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ramen Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: RamenTimerPage(),
    );
  }
}

class RamenTimerPage extends StatefulWidget {
  final title = 'Ramen Timer';
  @override
  State<StatefulWidget> createState() {
    return _RamenTimerPageStage();
  }
}

class _RamenTimerPageStage extends State<RamenTimerPage> {
  Timer timer;
  var timerStr = '03:00';
  int timerSec = 0;
  var running = false;
  final minController = TextEditingController(text: '00');
  final secController = TextEditingController(text: '00');

  void startTimer() {
    resetTimer();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timerSec == 0) {
          resetTimer();
        } else if (running) {
          updateTimerCount();
          timerSec--;
        }
      });
    });
  }

  void resetTimer() {
    timerSec = 180;
    running = false;
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    updateTimerCount();
  }

  void updateTimerCount() {
    int min = timerSec ~/ 60;
    int sec = (timerSec - min * 60) % 60;
    timerStr = '${min.toString().padLeft(2, "0")}:${sec.toString().padLeft(2, "0")}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              timerStr,
              style: Theme.of(context).textTheme.display1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    startTimer();
                  },
                  child: Text('Reset Timer'),
                ),
                RaisedButton(
                  onPressed: () {
                    running = !running;
                  },
                  child: Text(running ? 'Pause' : 'Resume'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}