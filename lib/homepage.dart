import 'dart:developer';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/booksearch_registration.dart';
import 'package:logging/logging.dart';
import 'authentication.dart';
import 'package:flutter_advanced_networkimage/provider.dart';

final log = Logger('HomePage');

class HomePage extends StatelessWidget {
  // This widget is the root of your application.
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  Widget build(BuildContext context) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });

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
  var cardList = List.generate(length, (index) => index);

  @override
  Widget build(BuildContext context) {
    int _counter = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(4),
              child: ListTile(
                leading: const FlutterLogo(),
                title: Text('ようこそ、$userId さん'),
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: StreamBuilder(
                stream: Firestore.instance.collection('books').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemCount: snapshot.data.documents.length,
                    padding: EdgeInsets.all(2.0),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/book_detail');
                            },
                            child: Column(
                              children: <Widget>[
                                Image(
                                  image: AdvancedNetworkImage(
                                    snapshot.data.documents[index]['thumbnail'],
                                    useDiskCache: true,
                                    cacheRule: CacheRule(
                                        maxAge: const Duration(days: 7)),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                Text(snapshot.data.documents[index]['title']),
                              ],
                            )),
                        padding: EdgeInsets.all(2.0),
                      );
                    },
                  );
                }),
          )
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
