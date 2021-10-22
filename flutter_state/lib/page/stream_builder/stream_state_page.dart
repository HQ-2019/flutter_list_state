//
//  Created by hq on 2020/8/4.
//  Copyright © 2020 flutter_state. All rights reserved.
//
//  StreamBuild状态管理（实现局部视图刷新）

import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StreamStatePage extends StatefulWidget {
  @override
  _StreamStatePage createState() => _StreamStatePage();
}

class _StreamStatePage extends State<StreamStatePage> {
  int _count = 0;

  final StreamController<int> _streamController = StreamController<int>();

  List<StreamController<DataModel>> _listStreamController = [];

  List<DataModel> _dataList = [];

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
        model.countDown = i + 5;
        model.name = '商品名称 $i';
//        // 随机设置一些不需要倒计时的
//        if (Random().nextInt(100) <= 30) {
//          model.countDown = 0;
//        }

        _dataList.add(model);

        StreamController<DataModel> streamC =
            StreamController<DataModel>.broadcast();
        _listStreamController.add(streamC);
        streamC.sink.add(model);
      }
      setState(() {});

      // 开始定时器，定时更新数据源中的倒计时数据
      openTimer();
    });
  }

  @override
  void dispose() {
    closeTimer();

    // 关闭流
    _streamController.close();
    for (StreamController<DataModel> streamController
        in _listStreamController) {
      streamController.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('StreamBuilder'),
      ),
      body: _buildListStreamView(context), // 构建列表streamBuilder
//      body: _buildSimpleStreamView(context),  // 构建简单的streamBuilder
    );
  }

  /// 构建一个列表视图演示 StreamBuilder 实现局部更新
  Widget _buildListStreamView(BuildContext context) {
    return ListView.separated(
        itemBuilder: (context, index) {
//          return ListItem(dataModel: _dataList[index], index: index);
          return StreamBuilder<DataModel>(
              // 监听Stream，每次值改变的时候，更新Text中的内容
              stream: _listStreamController[index].stream,
              initialData: _dataList[index],
              builder:
                  (BuildContext context, AsyncSnapshot<DataModel> snapshot) {
                print("$index  ${snapshot.data.countDown}");
                return ListItemView(dataModel: snapshot?.data, index: index);
              });
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: _dataList.length);
  }

  /// 构建一个简单视图演示 StreamBuilder
  Widget _buildSimpleStreamView(BuildContext context) {
    print("构建简单的StreamBuilder");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder<int>(
              // 监听Stream，每次值改变的时候，更新Text中的内容
              stream: _streamController.stream,
              initialData: _count,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                return Text('点击的时候这个值会改变: ${snapshot?.data}');
              }),
          RaisedButton(
            onPressed: () {
              _count++;
              _streamController.sink.add(_count);
            },
            child: Text('点击改变数据'),
          )
        ],
      ),
    );
  }

  /// 开启定时器
  void openTimer() {
    print("开始定时器");
    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        print("定时器事件");
        // 记录是否需要停止定时器（列表中所以的倒计时都归零后不再需要定时）
        bool needTimer = false;
        for (int i = 0; i < _dataList.length; i++) {
          DataModel model = _dataList[i];
          if (model.countDown > 0) {
            model.countDown -= 1;
            _listStreamController[i].sink.add(model);
            needTimer = true;
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

/// #########################  List item view    #########################

/// 使用StatefulWidget构建列表的item，才能在item的dispose中关流
class ListItemView extends StatefulWidget {
  DataModel dataModel;
  int index;

  ListItemView({Key key, this.dataModel, this.index});

  @override
  _ListItemView createState() => _ListItemView();
}

class _ListItemView extends State<ListItemView> {
  DataModel dataModel;
  int index;

  // 流控制器
  StreamController<DataModel> _streamController;

  @override
  void initState() {
    super.initState();
    dataModel = widget.dataModel;
    index = widget.index;

    // 创建流控制器
    _streamController = StreamController<DataModel>.broadcast();
    // 将数据添加到流控制器中
    _streamController.sink.add(dataModel);

    print("      创建  ${this.index}   ${this.dataModel.countDown}");
  }

  @override
  void dispose() {
    // 关流
    _streamController.close();
    super.dispose();
    print("销毁  ${this.index}  ${this.dataModel.countDown}");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(dataModel.name),
                    SizedBox(height: 20),
                    Container(
                      height: 50,
                      child: Text(getCountDownText(dataModel.countDown)),
                    )
                  ],
                )),
            StreamBuilder(
                stream: _streamController.stream,
                initialData: dataModel,
                builder:
                    (BuildContext context, AsyncSnapshot<DataModel> snapshot) {
                  return RaisedButton(
                    onPressed: () {
                      dataModel.collectState =
                          dataModel.collectState == 0 ? 1 : 0;
                      _streamController.sink.add(dataModel);

                      // 还应该同时更新数据源列表中的数据
                    },
                    child:
                        Text(snapshot.data.collectState == 0 ? "收藏" : "取消收藏"),
                  );
                })
          ],
        ));
  }

  String getCountDownText(int countDown) {
    if (countDown == null || countDown <= 0) {
      return "活动结束";
    }
    return "活动剩余时间 ${countDown}";
  }
}
