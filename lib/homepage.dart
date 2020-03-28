import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/booksearch_and_registration.dart';
import 'package:logging/logging.dart';
import 'authentication.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'header.dart';

final log = Logger('HomePage');

List<String> checkTitle = [];

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
          '/book_detail': (BuildContext context) => BookDetail(),
          '/booksearch_and_registration': (BuildContext context) =>
              BooksearchAndRegistration(),
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

  @override
  Widget build(BuildContext context) {
    String nickname;
    getNickname(userId).then((d) => nickname = d.toString());

    return Scaffold(
      appBar: Header(),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 0,
            child: Container(
              margin: const EdgeInsets.all(2.0),
              child: ListTile(
                leading: Icon(MaterialIcons.book),
                title: Text('ようこそ、$nickname さん'),
                dense: true,
              ),
            ),
          ),
          Expanded(
            flex: 8,
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
                    itemBuilder: (BuildContext context, int index) {
                      // titleの重複確認のため、このリストに格納
                      checkTitle.add(snapshot.data.documents[index]['title']);

                      return Container(
                        margin: EdgeInsets.all(8.0),
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black38,
                            width: 2.0,
                          ),
                          borderRadius:
                          new BorderRadius.all(new Radius.circular(10.0)),
                        ),
                        child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/book_detail');
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Image(
                                  image: AdvancedNetworkImage(
                                    snapshot.data.documents[index]['thumbnail'],
                                    height: 120,
                                    useDiskCache: true,
                                    cacheRule: CacheRule(
                                        maxAge: const Duration(days: 7)),
                                  ),
                                  fit: BoxFit.scaleDown,
                                ),
                                SpaceBox.height(4),
                                Text(snapshot.data.documents[index]['title'],
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontStyle: FontStyle.normal,
                                    )),
                              ],
                            )),
                      );
                    },
                  );
                }),
          ),
          Expanded(
            flex: 0,
            child: Container(
              margin: EdgeInsets.all(4.0),
              child: FloatingActionButton.extended(
//                onPressed: () => Navigator.of(context)
//                    .pushNamed('/booksearch_and_registration'),
                onPressed: () =>
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BooksearchAndRegistration(
                                  checkTitle: checkTitle,
                                ))),
                backgroundColor: Colors.blue,
                icon: Icon(Icons.add),
                label: const Text('本の追加'),
              ),
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

class SpaceBox extends SizedBox {
  SpaceBox({double width = 8, double height = 8})
      : super(width: width, height: height);

  SpaceBox.width([double value = 8]) : super(width: value);

  SpaceBox.height([double value = 8]) : super(height: value);
}

Future getNickname(String userId) async {
  DocumentSnapshot docSnapshot =
  await Firestore.instance.collection('users').document(userId).get();

  return docSnapshot['nickname'];
}
