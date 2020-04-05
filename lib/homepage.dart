import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'login_signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/booksearch_and_registration.dart';
import 'package:logging/logging.dart';
import 'authentication.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'header.dart';
import 'book_detail.dart';

final log = Logger('HomePage');
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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
        home: MyHomePage(
            title: 'ブックレンタルアプリ', auth: this.auth, userId: this.userId),
        routes: <String, WidgetBuilder>{
          '/login_signup': (BuildContext context) => LoginSignupPage(),
//          '/book_detail': (BuildContext context) => BookDetail(),
          '/booksearch_and_registration': (BuildContext context) =>
              BooksearchAndRegistration(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.auth, this.userId}) : super(key: key);

  final String title;
  final BaseAuth auth;
  final String userId;

  @override
  _MyHomePageState createState() =>
      _MyHomePageState(auth: auth, userId: userId);
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseUser user;
  final BaseAuth auth;

  _MyHomePageState({this.auth, this.userId});

  @override
  void initState() {
    super.initState();
//    initUser();
    // Firebase Messagingの通知許可の設定を行う
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });

    // ここで通知受信時の挙動を設定しています。
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        log.info("onMessage: $message['notification']['title']");
        log.info('ここ注目： ' + message['notification']['title'].toString());
        _buildDialog(context, message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _buildDialog(context, "onLaunch");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _buildDialog(context, "onResume");
      },
    );

    // 自らのTokenをGetし、Firestoreに保存する
    _firebaseMessaging.getToken().then((token) {
      log.info('token is ' + token);
      log.info('userId is ' + userId);

      var data = {
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
      };

      Firestore.instance.collection('users').document(userId).updateData(data);
    });
  }

  initUser() async {
    user = await auth.getCurrentUser();
    log.info('FirebaseAuthのユーザ： ' + userId.toString());
    setState(() {});
  }

  final String userId;
  String displayName = '名無し';

  @override
  Widget build(BuildContext context) {
//    getDisplayName(userId).then((d) => displayName = d.toString());
    Firestore.instance
        .collection('users')
        .document(userId)
        .get()
        .then((onValue) {
      displayName = onValue.data['displayName'].toString();
    });

    return Scaffold(
      appBar: Header(),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 0,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(2.0),
                    child: ListTile(
                      leading: Icon(MaterialIcons.book),
                      title: Text('ようこそ、$displayName さん'),
                      dense: true,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FlatButton(
                    child: Text(
                      'サインアウト',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () =>
                    {
                      auth.signOut(),
                      Navigator.of(context).pushNamed('/login_signup'),
                    },
                  ),
                )
              ],
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
                              log.info('homepageのbookは ' +
                                  snapshot.data.documents[index].toString());
                              // タップされた本情報としてsnapshot.data.documents[index]を渡す
//                              Navigator.of(context).pushNamed('/book_detail',
//                                  arguments: {
//                                    'book': snapshot.data.documents[index]
//                                  });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BookDetail(
                                            book:
                                            snapshot.data.documents[index],
                                            cloudmsg: _firebaseMessaging,
                                            displayName: displayName,
                                          )));
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

class SpaceBox extends SizedBox {
  SpaceBox({double width = 8, double height = 8})
      : super(width: width, height: height);

  SpaceBox.width([double value = 8]) : super(width: value);

  SpaceBox.height([double value = 8]) : super(height: value);
}

Future getDisplayName(String userId) async {
  DocumentSnapshot docSnapshot =
  await Firestore.instance.collection('users').document(userId).get();

  return docSnapshot['displayName'];
}

// FCMで表示するダイアログ
void _buildDialog(BuildContext context, dynamic message) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ListTile(
            leading: Icon(Icons.book),
            title: Text(message['notification']['title']),
            subtitle: Text(message['notification']['body']),
          ),
          actions: <Widget>[
            new FlatButton(
              child: const Text('CLOSE'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      });
}
