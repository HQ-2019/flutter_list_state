//
//  Created by hq on 2020/8/4.
//  Copyright © 2020 flutter_state. All rights reserved.
//
// 一个有时间倒计时功能的视图

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 定时器活动回调剩余倒计时长
typedef TimerAction = void Function(int time);

class CountdownWidget extends StatefulWidget {
  // 倒计时持续时长（单位秒）
  int duration;

  // 标题
  final String title;

  // 倒计时结束时的回调
  final Function timerFinish;

  // 定时器活动回调
  final TimerAction timerAction;

  CountdownWidget(
      {Key key,
        @required this.duration,
        this.title,
        this.timerFinish,
        this.timerAction})
      : super(key: key);

  @override
  _CountdownWidget createState() => _CountdownWidget();
}

class _CountdownWidget extends State<CountdownWidget> {
  // 定时器
  Timer _timer;

  int _day;
  int _hours;
  int _minute;
  int _second;

  @override
  void initState() {
    super.initState();
    // 格式化时间
    formatTime(widget.duration);
    // 开启定时器
    openTimer();
  }

  @override
  void dispose() {
    super.dispose();

    if (_timer != null) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      children: <Widget>[
        widget.title == null
            ? SizedBox(width: 0)
            : Row(
          children: <Widget>[
            Text(widget.title,
                textScaleFactor: 1.0,
                style:
                TextStyle(color: Colors.black54, fontSize: 12)),
            SizedBox(width: 5)
          ],
        ),
        circularText(_day.toString(), suffix: '天'),
        circularText(stringForInt(_hours), suffix: ':'),
        circularText(stringForInt(_minute), suffix: ':'),
        circularText(stringForInt(_second)),
      ],
    );
  }

  /// 创建有圆形背景的文本
  Widget circularText(String text, {String suffix}) {
    // 数据为0时不显示，但是为00时需要显示
    if (int.parse(text) <= 0 && text != '00') {
      return SizedBox(width: 0);
    }
    return Row(
      children: <Widget>[
        Container(
          width: 16,
          height: 16,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8)),
          child: Text(
            text,
            textScaleFactor: 1.0,
            style: TextStyle(
                color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ),
        suffix == null
            ? SizedBox(
          width: 0,
        )
            : Text(
          suffix,
          textScaleFactor: 1.0,
          style: TextStyle(
              color: Colors.black54,
              fontSize: 10,
              fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  /// 将int的时间单元转换成字符串
  String stringForInt(int value) {
    return value <= 0 ? '00' : value.toString();
  }

  /// 将倒计时长分解
  void formatTime(int time) {
    _day = time ~/ 3600 ~/ 24;
    _hours = (time % (3600 * 24)) ~/ 3600;
    _minute = time % 3600 ~/ 60;
    _second = time % 60;
  }

  /// 开启定时器
  void openTimer() {
    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        // 更新时间
        setState(() {
          widget.duration -= 1;
          formatTime(widget.duration);
          if (widget.duration <= 0) {
            // 倒计时结束 关闭定时器
            closeTimer();
            if (widget.timerFinish != null) {
              widget.timerFinish();
            }
          } else {
            if (widget.timerAction != null) {
              widget.timerAction(widget.duration);
            }
          }
        });
      });
    }
  }

  /// 关闭定时器
  void closeTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }
}