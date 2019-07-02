import 'package:flutter/material.dart';
import 'dart:async';

class RamenTimerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: RamenTimerPage(),
    );
  }
}

class RamenTimerPage extends StatefulWidget {
  final title = 'Timer';
  @override
  State<StatefulWidget> createState() {
    return _RamenTimerPageStage();
  }
}

class _RamenTimerPageStage extends State<RamenTimerPage> {
  Timer _timer;
  var _timerStr = '00:00';
  var _timerSec = 0;
  var _running = false;
  var _isStarted = false;
  var _leftButtonStr = '+Min';
  var _rightButtonStr = 'Start';

  void _prepareTimer() {
    _isStarted = true;
    _leftButtonStr = 'Reset';
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerSec == 0) {
        _resetTimer();
      } else if (_running) {
        _updateTimerCount();
        _timerSec--;
      }
    });
  }

  void _startTimer() {
    _running = true;
    setState(() {
      _rightButtonStr = 'Stop';
    });
  }

  void _stopTimer() {
    _running = false;
    setState(() {
      _rightButtonStr = 'Start';
    });
  }

  void _incrementMinutes() {
    _timerSec += 60;
    _updateTimerCount();
  }

  void _resetTimer() {
    _stopTimer();
    _timerSec = 0;
    _isStarted = false;
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    _updateTimerCount();
    _leftButtonStr = '+Min';
  }

  void _updateTimerCount() {
    int min = _timerSec ~/ 60;
    int sec = (_timerSec - min * 60) % 60;
    setState(() {
      _timerStr = '${min.toString().padLeft(2, "0")}:${sec.toString().padLeft(2, "0")}';
    });
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
              _timerStr,
              style: Theme.of(context).textTheme.display1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: () {
                    if (_isStarted) {
                      _resetTimer();
                    } else {
                      _incrementMinutes();
                    }
                  },
                  child: Text(_leftButtonStr),
                ),
                RaisedButton(
                  onPressed: () {
                    if (!_isStarted) {
                      _prepareTimer();
                      _startTimer();
                    } else {
                      if (_running) {
                        _stopTimer();
                      } else {
                        _startTimer();
                      }
                    }
                  },
                  child: Text(_rightButtonStr),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _resetTimer();
  }
}