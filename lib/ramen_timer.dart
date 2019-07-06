import 'dart:async';

import 'package:flutter/material.dart';

class RamenTimerApp extends StatelessWidget {
  final title = 'Timer';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer',
      theme: ThemeData(primarySwatch: Colors.blue),
      // 今雑にこっちに移動してしまったが、個人的には、viewと分離して考えたいし
      // StatefulWidgetに余分なものは持たせたくはない
      home: Scaffold(
        appBar: AppBar(
          title: Text('Timer'),
        ),
        body: RamenTimerPage(),
      ),
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

enum TimerState {
  Init,
  Stop,
  Running,
}

// このぐらいならいいけど、問題として、状態変更ができていない、setStateが呼ばれるタイミング的に、
// Startにならないところがあるので、仕方なく、setStateを使ってしまっているように見えるけれど、
// 基本的に状態変更がおきた場合、setStateを呼んだほうがいいと思う。じゃないとどの結果をStateに反映していて、
// どの結果を反映しないのかが、わかりにくくなってしまうから、なので、 出来るだけ、setStateのロジックはまとめて書いたり、
// それぞれの変数に対して、引数をsetするような関数があると、明示的でとてもわかりやすい気がする -> 例
// ただ、こうすると多くの状態ごとにsetStateを作ることになるので、まとめていきたいので、部品ごとにStateを管理するのが理想では
//　あるかなとも思うが、それはそれで大変なのと、呼びすぎて挙動が遅くなったりしてから考えればいいとと思っている
// だから状態をStreamで管理したほうがいいというGoogleの意図が見えるってのもあるけど

class _RamenTimerPageStage extends State<RamenTimerPage> {
  Timer _timer;
  // この二つの分離はいい感じ
  var _timerStr = '00:00';
  var _timerSec = 0;
  // 両方ともこのタイマーの状態なので、二つの変数に分けてると意味合いが分離してしまっているようになるので、
  // 一つのStateにまとめたい
//  var _running = false;
//  var _isStarted = false;
  var _timerState = TimerState.Init;
  // この以下の二つの変数も時間と同じように、表示される文字列と、表示している文字列を分けたい
  // 出ないと、どちらにどんな文字列が表示されるかが、コード全体を読んで、散ってしまっている
  // 表示ロジックを追って初めて理解できるようになってしまうから
  var _leftButtonStr = '+Min';
  var _rightButtonStr = 'Start';

  // コールバックで呼び出しても別に問題はないけれど、個人的にはみとうしが良くないのと
  // 無駄に複雑性がますように感じている、ただでさえ、コールバックは結合度が制御結合なので
  // 少しでも見通しをよくしたい、ただ、階層構造を同レベルで保ちたい場合などは別
  void _timerLogic(Timer timer) {
    if (_timerSec == 0) {
      _resetTimer();
    } else if (_timerState == TimerState.Running) {
      _updateTimerCount();
      _timerSec--;
    }
  }

  // 例
//  void _setTimer(Timer timer) {
//    setState(() {
//      _timer = timer;
//    });
//  }
//
//  void _setLeftButtonStr(String str){
//    setState(() {
//      _leftButtonStr = str;
//    });
//  }
//
//  void _setLeftButtonResetSet() {
//    _setLeftButtonStr("Reset");
//  }
//
//
//  void _prepareTimer() {
//    _setLeftButtonResetSet();
//    _setTimer(Timer.periodic(Duration(seconds: 1), _timerLogic));
//  }
//

  void _prepareTimer() {
//    _isStarted = true;
//    _leftButtonStr = 'Reset';
    setState(() {
      _leftButtonStr = 'Reset';
      _timer = Timer.periodic(Duration(seconds: 1), _timerLogic);
    });
  }

  void _startTimer() {
//    _running = true;
    setState(() {
      _timerState = TimerState.Running;
      _rightButtonStr = 'Stop';
    });
  }

  void _stopTimer() {
//    _running = false;
    setState(() {
      _timerState = TimerState.Stop;
      _rightButtonStr = 'Start';
    });
  }

  void _add60sec() {
    setState(() {
      _timerSec += 60;
    });
  }

  // やっていることの階層レベルをそれ得るために関数を分ける。出ないとここやりたいことが、スコープによって、
  // 表現レベルの差が出てしまう,個人的にはここは全部インクリメントとアップデートを同じ関数でやりたくはない
  void _incrementMinutes() {
    _add60sec();
    _updateTimerCount();
  }

  void _resetTimer() {
    _stopTimer();
    _timerSec = 0;
//    _isStarted = false;
    _timerState = TimerState.Init;
// _timer? ?? false
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    _updateTimerCount();
    _leftButtonStr = '+Min';
  }

  // こんな感じで、計算ロジックを完全に分離して、それをStrで返すロジックもまた別にするべき
  // 関数は常に一つのことに集中すべきだから
  int _min() {
    int min = _timerSec ~/ 60;
    return min;
  }

  int _sec() {
    int sec = (_timerSec - _min() * 60) % 60;
    return sec;
  }

  String _timeToStr(int t) {
    return t.toString().padLeft(2, "0");
  }

  void _updateTimerCount() {
    setState(() {
      _timerStr = '${_timeToStr(_min())}:${_timeToStr(_sec())}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // ここも今現状同じbuttonの状態を変更しているが、
                // これも、個人的には同じものではないので、Start, Stop, Reset, +Minの
                // 4つを定義し、それらを切り替えたほうが自然に思える
                // あと、Running状態で左のボタンの表示時がResetになっているが、+Minの挙動になっているので、
                // そこも直しておきたい
                RaisedButton(
                  onPressed: () {
                    if (_timerState == TimerState.Stop) {
                      _resetTimer();
                    } else {
                      _incrementMinutes();
                    }
                  },
                  child: Text(_leftButtonStr),
                ),
                RaisedButton(
                  onPressed: () {
                    switch (_timerState) {
                      case TimerState.Init:
                        _prepareTimer();
                        _startTimer();
                        break;
                      case TimerState.Stop:
                        _startTimer();
                        break;
                      case TimerState.Running:
                        _stopTimer();
                        break;
                    }
//                    if (!_isStarted) {
//                      // TimerState.Runningにする
//                      _prepareTimer();
//                      _startTimer();
//                    } else {
//                      if (_running) {
//                        // TimerState.Stopにする
//                        _stopTimer();
//                      } else {
//                        // TimerState.Runningにする
//                        _startTimer();
//                      }
//                    }
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
