import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'authentication.dart';

class HomePage extends StatelessWidget {
  // This widget is the root of your application.
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//        title: 'ブックレンタルアプリ',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'ブックレンタルアプリ', userId: this.userId),
        routes: <String, WidgetBuilder>{
          '/book_detail': (BuildContext context) => new BookDetail(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.userId}) : super(key: key);

  final String title;
  final String userId;

  @override
  _MyHomePageState createState() => _MyHomePageState(userId: userId);
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState({this.userId});

  final String userId;

  // TODO: グループIDで登録されている本の一覧をDBから取得し、そのレコード数をCardの要素数とする
  static int length = 30;
  var cardlist = List.generate(length, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Row(
              children: <Widget>[
                const FlutterLogo(),
                const Expanded(
                  child: Text('ようこそ！ 岡崎 さん'),
                ),
                const Icon(Icons.sentiment_very_satisfied),
              ],
            ),
          ),
          Expanded(
            flex: 9,
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(16.0),
              childAspectRatio: 8.0 / 9.0,
              children: <Widget>[
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: 18.0 / 11.0,
                        child: Image.asset(
                            'assets/f_f_object_174_s128_f_object_174_0bg.png'),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Title'),
                            SizedBox(height: 8.0),
                            Text('First Text'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed('/book_detail');
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 18.0 / 11.0,
                          child: Image.asset(
                              'assets/f_f_object_174_s128_f_object_174_1bg.png'),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Title'),
                              SizedBox(height: 8.0),
                              Text('Secondry Text'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookDetail extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _BookDetailState createState() => new _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text('BookDetail')),
      body: Container(),
    );
  }
}
