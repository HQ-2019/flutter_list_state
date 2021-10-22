//
//  Created by hq on 2020/8/7.
//  Copyright © 2020 flutter_state. All rights reserved.
//

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state/page/custom_provider/custom_provider_page.dart';

class ValueListenablePage extends StatefulWidget {
  @override
  _ValueListenablePage createState() => _ValueListenablePage();
}

class _ValueListenablePage extends State<ValueListenablePage> {
  List<ValueNotifier<DataModel>> _dataList = [];

  // 定时器
  Timer _timer;

  @override
  void initState() {
    super.initState();

    // 模拟网络请求延时获取数据
    Future.delayed(Duration(seconds: 1), () {
      // 模拟数据
      for (int i = 0; i <= 30; i++) {
        DataModel model = DataModel();
        model.countDown = i + 10;
        model.name = '商品名称 $i';
//        // 随机设置一些不需要倒计时的
//        if (Random().nextInt(100) <= 30) {
//          model.countDown = 0;
//        }

        _dataList.add(ValueNotifier<DataModel>(model));
      }
      setState(() {});

      // 开始定时器，定时更新数据源中的倒计时数据
      openTimer();
    });
  }

  @override
  void dispose() {
    closeTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('ValueListenable'),
      ),
      body: _buildListView(context),
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
          return ValueListenableBuilder(
              valueListenable: _dataList[index],
              builder: (BuildContext context, DataModel model, Widget child) {
                print("更新 index : $index");
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 不需要更新的视图
                    child,
                    // 需要更新的视图
                    Text("index：$index    倒计时：${model.countDown}"),
                  ],
                );
              },
            // 不需要进行更新的视图
            child: Column(
              children: <Widget>[
                Text(_dataList[index].value.name),
                SizedBox(height: 10),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: _dataList.length);
  }

  /// 开启定时器
  void openTimer() {
    print("开始定时器");
    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        // 记录是否需要停止定时器（列表中所以的倒计时都归零后不再需要定时）
        bool needTimer = false;
        for (int i = 0; i < _dataList.length; i++) {
          if (_dataList[i].value.countDown > 0) {
            needTimer = true;
            DataModel model = DataModel();
            model.name = _dataList[i].value.name;
            model.countDown = _dataList[i].value.countDown - 1;

            // 必须重新创建一个model并通过.value = model 进行赋值
            // 如果直接通过_dataList[i].value.countDown -= 1; 进行修改值，无法触发.value方法中的notifyListeners(),导致视图无法更新数据
            // 这种修改数据的方式比较麻烦，如何想要实现值针对某个字段变更时更新UI，则可以自定义可发布通知的Model（可参考ValueNotifier的实现）, 在某字段变更时调notifyListeners()
            _dataList[i].value = model;
          }
        }

        if (!needTimer) {
          closeTimer();
        }
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

class DataModel {
  // 活动倒计时
  int countDown = 0;

  // 商品名称
  String name;

  // 收藏状态 0为收藏 1已收藏
  int collectState = 0;
}
