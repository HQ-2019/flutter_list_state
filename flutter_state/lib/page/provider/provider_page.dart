//
//  Created by hq on 2020/8/4.
//  Copyright © 2020 flutter_state. All rights reserved.
//
// 使用provider管理列表数据更新

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProviderPage extends StatefulWidget {
  @override
  _ProviderPage createState() => _ProviderPage();
}

class _ProviderPage extends State<ProviderPage> {

  List<DataModel> _dataList = [];

  @override
  void initState() {
    super.initState();

    // 2秒后获取数据更新UI
    Future.delayed(Duration(seconds: 2), () {
      // 模拟数据
      for (int i = 0; i <= 50; i++) {
        DataModel model = DataModel();
        // model.countDown = Random().nextInt(100);
        model.countDown = i;
        print('随机数 ${model.countDown}');
        _dataList.add(model);
      }
        setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Privoder'),
      ),
      body: _buildListView(context),
    );
  }

  Widget _buildListView(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
            return Text( 'index :  ' + _dataList[index].countDown.toString());
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: _dataList.length);
  }
}

/// 具备发出通知的数据模型
class DataModel extends ChangeNotifier {
    int countDown = 0;
    String str;

    void increment() {
      countDown++;
      notifyListeners();
    }
}