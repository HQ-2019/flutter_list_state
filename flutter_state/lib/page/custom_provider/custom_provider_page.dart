//
//  Created by hq on 2020/8/4.
//  Copyright © 2020 flutter_state. All rights reserved.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomProviderPage extends StatefulWidget {
  @override
  _CustomProviderPage createState() => _CustomProviderPage();
}

class _CustomProviderPage extends State<CustomProviderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('自定义Provider'),
      ),
      body: Center(
        child: ModelProviderWidget<DataModel>(
          data: DataModel(count: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Consumer<DataModel>(
                  builder: (context, value) => Text("count: ${value.count}")),
              Builder(builder: (context) {
                print("构建按钮");
                return RaisedButton(
                  onPressed: () {
                    DataModel model = ModelProviderWidget.of<DataModel>(context, listen: false);
                    model.dataIncrement();
//                    ModelProviderWidget.of<DataModel>(context, listen: false)
//                        .dataIncrement();
                  },
                  child: Text("更新数据"),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class Consumer<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T value) builder;

  const Consumer({Key key, @required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Consumer build");
//    T value = ModelProviderWidget.of<T>(context);
    return builder(context, ModelProviderWidget.of<T>(context));
  }
}

/// 统一管理ProviderInheritedWidget和DataModel
class ModelProviderWidget<T extends NotifyModel> extends StatefulWidget {
  final T data;

  final Widget child;

  // context为当前widget的context （当前无效，未能解决问题）
  static T of<T>(BuildContext context, {bool listen = true}) {
    final provider = listen
        ? context.dependOnInheritedWidgetOfExactType<ProviderInherited<T>>()
        : context.getElementForInheritedWidgetOfExactType<ProviderInherited<T>>()?.widget
    as ProviderInherited<T>;

    if (provider == null) {
       return null;
    }

    return provider.data;

//    if (listen) {
//      ProviderInherited xx = context.dependOnInheritedWidgetOfExactType<ProviderInherited<T>>();
//      return xx.data;
//    }
//
//    ProviderInherited yy = context.getElementForInheritedWidgetOfExactType<ProviderInherited<T>>() as ProviderInherited;
//    return yy.data;

//    return (listen
//            ? context.dependOnInheritedWidgetOfExactType<ProviderInherited<T>>()
//            : (context
//                .getElementForInheritedWidgetOfExactType<ProviderInherited<T>>()
//                .widget as ProviderInherited<T>))
//        .data;
  }

  const ModelProviderWidget({Key key, this.data, this.child}) : super(key: key);

  @override
  _ModelProviderWidget createState() => _ModelProviderWidget();
}

class _ModelProviderWidget<T extends NotifyModel>
    extends State<ModelProviderWidget> {
  void notify() {
    setState(() {
      print('通知到达');
    });
  }

  @override
  void initState() {
    // 添加监听
    widget.data.addListener(notify);
    super.initState();
  }

  @override
  void dispose() {
    // 移除监听
    widget.data.removeListener(notify);
    super.dispose();
  }

  @override
  void didUpdateWidget(ModelProviderWidget<NotifyModel> oldWidget) {
    // data更新时移除旧的data监听
    if (oldWidget.data != widget.data) {
      oldWidget.data.removeListener(notify);
      widget.data.addListener(notify);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ProviderInherited<T>(
      data: widget.data,
      child: widget.child,
    );
  }
}

/// 数据模型
class DataModel extends NotifyModel {
  int count = 0;

  DataModel({this.count});

  // 数据变更
  void dataIncrement() {
    count++;

    // 通知观察者数据已变更
    notifyDataChanged();
  }
}

/// 监听数据的变化，并通知观察者
class NotifyModel implements Listenable {
  List _listeners = [];

  @override
  void addListener(listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(listener) {
    _listeners.remove(listener);
  }

  // 数据发送变化时 给观察者发送通知
  void notifyDataChanged() {
    _listeners.forEach((element) => element());
  }
}

/// 实现一个自定义的inheritedWidget, 用来提供共享数据源和接收缓存的child
class ProviderInherited<T> extends InheritedWidget {
  final T data;
  final Widget child;

  ProviderInherited({@required this.data, this.child});

  @override
  bool updateShouldNotify(ProviderInherited oldWidget) {
    // 返回true 表示通知树中依赖该共享数据的子Widget
    return true;
  }
}
