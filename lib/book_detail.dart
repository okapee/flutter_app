import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'header.dart';
import 'package:logging/logging.dart';
import 'package:flutter_app/homepage.dart';
import 'authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_functions/cloud_functions.dart';

final log = Logger('BookDetail');

class BookDetail extends StatelessWidget {
  BookDetail({Key key,
    this.auth,
    this.logoutCallback,
    this.book,
    this.cloudmsg,
    this.displayName})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final DocumentSnapshot book;
  final FirebaseMessaging cloudmsg;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });

    final HttpsCallable callable = CloudFunctions.instance
        .getHttpsCallable(functionName: 'sendMessage')
      ..timeout = const Duration(seconds: 30);

    log.info('book in book_detail is ' + book.toString());

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: Header(),
          body: BookDetailScreen(book: book),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
//              cloudmsg.subscribeToTopic("/topics/gsacademy");
//              _buildDialog(context, '通知の受信を開始します');
              log.info('book.data is ' +
                  book.data['registerUser'] +
                  ' displayName is ' +
                  displayName +
                  ' title is ' +
                  book.data['title']);
              final HttpsCallableResult result = await callable.call(
                <String, dynamic>{
                  'registerUser': book.data['registerUser'],
                  'displayName': displayName,
                  'bookTitle': book.data['title'],
                },
              );
            },
            icon: Icon(Icons.check_circle),
            label: Text("借りたい"),
          ),
        ));
  }
}

class BookDetailScreen extends StatefulWidget {
  BookDetailScreen({this.book});

  DocumentSnapshot book;

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState(book: book);
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  _BookDetailScreenState({this.book});

  DocumentSnapshot book;

  @override
  Widget build(BuildContext context) {
    double rating = 0.0;
    String registerUser = book.data['registerUser'] ?? '名無し';
    String review = book.data['review'] ?? 'レビューはありません。';

    log.info('book in book_detail is ' + book.toString());
    return Container(
      margin: EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: <Widget>[
            Image(
              image: AdvancedNetworkImage(
                book.data['thumbnail'],
//                height: 120,
                useDiskCache: true,
                cacheRule: CacheRule(maxAge: const Duration(days: 7)),
              ),
              fit: BoxFit.scaleDown,
            ),
            SpaceBox.height(20),
            Text(book.data['title'].toString()),
            SpaceBox.height(20),
            Text('登録者： ' + registerUser + ' さん'),
            SpaceBox.height(20),
            Text('登録者おすすめ度'),
            SmoothStarRating(
              rating: rating = book.data['rating'] ?? 0.0,
              size: 40,
              filledIconData: Icons.star,
              halfFilledIconData: Icons.star_half,
              defaultIconData: Icons.star_border,
              starCount: 5,
              allowHalfRating: false,
              spacing: 2.0,
            ),
            SpaceBox.height(20),
            Text('登録者レビュー'),
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 10),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                color: Colors.white70,
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
              child: Text(review),
            ),
          ],
        ),
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

void _buildDialog(BuildContext context, String message) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          content: new Text("$message"),
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
