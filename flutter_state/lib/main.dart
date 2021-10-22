import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state/page/custom_provider/custom_provider_page.dart';
import 'package:flutter_state/page/stream_builder/stream_state_page.dart';
import 'package:flutter_state/page/provider/provider_page.dart';
import 'package:flutter_state/page/value_listenable/value_listenable_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  // 用于路由返回监听
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [MyApp.routeObserver],
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RouteAware{

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 添加监听订阅
    MyApp.routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    super.dispose();
    // 移除监听订阅
    MyApp.routeObserver.unsubscribe(this);
  }

  @override
  void didPush() {
    super.didPush();
    print("push进入myhome页面");
  }

  @override
  void didPushNext() {
    super.didPushNext();
    print("push到下一个页面");
  }

  @override
  void didPop() {
    super.didPop();
    print("pop出当前页面");
  }

  @override
  void didPopNext() {
    super.didPopNext();
    print("从其他页面pop回来");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                onPressed: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => StreamStatePage()));
                },
                child: Text('使用Stream实现局部更新')
            ),
            RaisedButton(
                onPressed: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => ProviderPage()));
                },
                child: Text('使用provider实现局部更新')
            ),
            RaisedButton(
                onPressed: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => ValueListenablePage()));
                },
                child: Text('使用ValueListenable实现局部更新')
            ),
            RaisedButton(
                onPressed: () {
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => CustomProviderPage()));
                },
                child: Text('自定义provider')
            ),
          ],
        ),
      ),
    );
  }
}
