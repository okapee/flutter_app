import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/homepage.dart';
import 'authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:logging/logging.dart';
import 'package:flash/flash.dart';
import 'flash_helper.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

final log = Logger('BooksearchAndRegistration');

class BooksearchAndRegistration extends StatelessWidget {
  BooksearchAndRegistration(
      {Key key, this.auth, this.userId, this.logoutCallback, this.checkTitle})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final List<String> checkTitle;

  @override
  Widget build(BuildContext context) {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });

    log.info('本のタイトル重複チェック： checkTitle is ' + checkTitle.toString());

    return MaterialApp(
        title: '書籍検索',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SearchAndRegistration(title: 'ブックレンタルアプリ', userId: this.userId),
        routes: <String, WidgetBuilder>{
          '/book_detail': (BuildContext context) => BookDetail(),
          '/homepage': (BuildContext context) => HomePage(),
        });
  }
}

class SearchAndRegistration extends StatefulWidget {
  SearchAndRegistration({Key key, this.title, this.userId}) : super(key: key);

  final String title;
  final String userId;

  _SearchAndRegistrationState createState() =>
      _SearchAndRegistrationState(userId: userId);
}

class _SearchAndRegistrationState extends State<SearchAndRegistration> {
  _SearchAndRegistrationState({this.userId});

  final String userId;
  Future<List<Book>> _bookdata;
  List<Book> bookList = [];
  double rating = 0;

  final myController = TextEditingController();

  void _reload() {
    _bookdata = buildItemList(bookList, myController.text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      flex: 8,
                      child: TextField(
                        controller: myController,
                        decoration: InputDecoration(
                          hintText: '検索したいキーワードを入力',
                          filled: true,
                          prefixIcon: Icon(
                            Icons.book,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              _reload();
                              WidgetsBinding.instance.addPostFrameCallback(
                                      (_) => myController.clear());
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
            Expanded(
              flex: 8,
              child: Center(
                child: (bookList == null)
                    ? Text("Book List is displayed here!")
                    : FutureBuilder<List<Book>>(
                    future: _bookdata,
                    builder: (context, _bookdata) {
                      return ListView.builder(
                          itemCount: bookList.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 4.0,
                              child: ListTile(
                                contentPadding: EdgeInsets.all(4.0),
                                leading: Image(
                                  image: AdvancedNetworkImage(
                                    bookList[index].thumbnail,
                                    height: 120,
                                    useDiskCache: true,
                                    cacheRule: CacheRule(
                                        maxAge: const Duration(days: 7)),
                                  ),
                                  fit: BoxFit.scaleDown,
                                ),
                                title: Text("${bookList[index].title}"),
                                onTap: () {
                                  final _reviewController =
                                  TextEditingController();
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(content:
                                        StatefulBuilder(builder:
                                            (BuildContext context,
                                            StateSetter setState) {
                                          return Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceEvenly,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
//                                                      color: Colors.blue,
                                                    child: Text(
                                                      "本の登録",
                                                      style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 28,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Image(
                                                    image:
                                                    AdvancedNetworkImage(
                                                      bookList[index]
                                                          .thumbnail,
                                                      height: 120,
                                                      useDiskCache: true,
                                                      cacheRule: CacheRule(
                                                          maxAge:
                                                          const Duration(
                                                              days: 7)),
                                                    ),
                                                    fit: BoxFit.scaleDown,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                      "${bookList[index]
                                                          .title}" +
                                                          " を登録する場合、おすすめ度とレビューを入力してください。"),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text("おすすめ度",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                      )),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: SmoothStarRating(
                                                    rating: rating,
                                                    size: 40,
                                                    filledIconData:
                                                    Icons.star,
                                                    halfFilledIconData:
                                                    Icons.star_half,
                                                    defaultIconData:
                                                    Icons.star_border,
                                                    starCount: 5,
                                                    allowHalfRating: false,
                                                    spacing: 2.0,
                                                    onRatingChanged:
                                                        (value) {
                                                      setState(() {
                                                        rating = value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: TextField(
                                                    controller:
                                                    _reviewController,
                                                    maxLength: 30,
                                                    maxLengthEnforced:
                                                    false,
                                                    style: TextStyle(
                                                        color:
                                                        Colors.black),
                                                    obscureText: false,
                                                    maxLines: 1,
                                                    decoration:
                                                    InputDecoration(
                                                      labelText:
                                                      "レビューを入力してね！",
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    children: [
                                                      RaisedButton(
                                                        child: Text("登録"),
                                                        color: Colors.blue,
                                                        textColor:
                                                        Colors.white,
                                                        onPressed: () {
                                                          if (checkTitle
                                                              .contains(
                                                              bookList[
                                                              index]
                                                                  .title)) {
                                                            log.info(
                                                                '2重登録チェック');
                                                            Navigator.of(
                                                                context)
                                                                .pop();
                                                            Scaffold.of(
                                                                context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content:
                                                                const Text(
                                                                    '該当の本は既に登録されています。'),
                                                                duration: const Duration(
                                                                    seconds:
                                                                    5),
                                                              ),
                                                            );
                                                          } else {
                                                            Map<String,
                                                                dynamic>
                                                            book_data =
                                                            <String,
                                                                dynamic>{
                                                              "authors": bookList[
                                                              index]
                                                                  .authors,
                                                              "categories":
                                                              bookList[
                                                              index]
                                                                  .categories,
                                                              "description":
                                                              bookList[
                                                              index]
                                                                  .description,
                                                              "pageCount": bookList[
                                                              index]
                                                                  .pageCount,
                                                              "publishedDate":
                                                              bookList[
                                                              index]
                                                                  .publishedDate,
                                                              "publisher": bookList[
                                                              index]
                                                                  .publisher,
                                                              "thumbnail": bookList[
                                                              index]
                                                                  .thumbnail,
                                                              "title": bookList[
                                                              index]
                                                                  .title,
                                                              "registerUser":
                                                              userId,
                                                              "rating":
                                                              rating,
                                                              "review":
                                                              _reviewController
                                                                  .text
                                                            };
                                                            setData('books',
                                                                book_data);
                                                            Navigator.push(
                                                                context,
                                                                new MaterialPageRoute(
                                                                    builder:
                                                                        (
                                                                        context) =>
                                                                    new HomePage()));
                                                            Scaffold.of(
                                                                context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content:
                                                                const Text(
                                                                    '登録が完了しました。'),
                                                                duration: const Duration(
                                                                    seconds:
                                                                    5),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                      RaisedButton(
                                                        color: Colors.blue,
                                                        textColor:
                                                        Colors.white,
                                                        child:
                                                        Text("Close"),
                                                        onPressed: () {
                                                          Navigator.of(
                                                              context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ]);
                                        }));
                                      });
                                },

//                                    onTap: () {
//                                      log.info('ListTileのonTap実行');
//                                      showCustomDialogWithImage(
//                                          context,
//                                          bookList[index].authors,
//                                          bookList[index].categories,
//                                          bookList[index].description,
//                                          bookList[index].pageCount,
//                                          bookList[index].publishedDate,
//                                          bookList[index].publisher,
//                                          bookList[index].thumbnail,
//                                          bookList[index].title);
//                                    },
                              ),
                            );
                          });
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AwesomeDialog extends StatefulWidget {
  @override
  _AwesomeDialogState createState() => _AwesomeDialogState();
}

class _AwesomeDialogState extends State<AwesomeDialog> {
  bool _isAwesome;
  String _awesomeText;

  @override
  void initState() {
    super.initState();
    _isAwesome = false;
    _awesomeText = 'please tap Awesome..';
  }

  Widget _buildAwesomeButton() {
    return RaisedButton(
      child: Text(_awesomeText),
      onPressed: () {
        setState(() {
          _isAwesome = !_isAwesome;
          _awesomeText = _isAwesome ? 'u a Awesome!' : 'please tap Awesome..';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('It says'),
      children: <Widget>[
        const Text('Flutter is awesome.'),
        _buildAwesomeButton(),
      ],
    );
  }
}

// TODO: ここ削除予定
void showCustomDialogWithImage(BuildContext context,
    List<String> authors,
    List<String> categories,
    String description,
    int pageCount,
    String publishedDate,
    String publisher,
    String thumbnail,
    String title) {
  // 登録者のレビューを格納する変数
  String _review;
  final myController = TextEditingController();

  log.info('aiueo');

  // 登録用のMapを作成
  Map<String, dynamic> book_data = <String, dynamic>{
    "authors": authors,
    "categories": categories,
    "description": description,
    "pageCount": pageCount,
    "publishedDate": publishedDate,
    "publisher": publisher,
    "thumbnail": thumbnail,
    "title": title,
  };

  log.info('カスタムダイアログを表示する。book_data is ' + book_data.toString());

  FlashHelper.init(context);

  Dialog dialogWithImage = Dialog(
    child: Container(
      height: 300.0,
      width: 300.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.grey[300]),
            child: Text(
              "登録画面",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(title + ' を登録する場合、評価とおすすめポイントを入力し、OKを押してください。'),
                TextField(
                  controller: myController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  textAlign: TextAlign.left,
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              RaisedButton(
                  color: Colors.blue,
                  child: Text('登録',
                      style: TextStyle(fontSize: 18.0, color: Colors.white)),
                  onPressed: () {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('登録が完了しました。'),
                        duration: const Duration(seconds: 5),
                      ),
                    );

                    if (checkTitle.contains(book_data['title'])) {
                      log.info('2重登録チェック');
                      Navigator.pop(context);
                    } else {
                      setData('books', book_data);
                      Navigator.of(context).pushNamed('/homepage');
                    }
                  }),
              SizedBox(
                width: 20,
              ),
              RaisedButton(
                color: Colors.red,
                onPressed: () {
                  // カスタムダイアログを閉じる
                  Navigator.of(context).pop();
                },
                child: Text(
                  'キャンセル',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  log.info('showDialog実行');
  showDialog(
      context: context, builder: (BuildContext context) => dialogWithImage);
}

Future<List<Book>> buildItemList(List<Book> bookList, String input) async {
  String baseUrl = 'https://www.googleapis.com/books/v1/volumes?q=';
  String getUrl = baseUrl + input;

  final response = await http.get(getUrl);

  if (response.statusCode == 200) {
    bookList.clear();
    Map<String, dynamic> map = json.decode(response.body);
    List data = map["items"];

    for (int i = 0; i < data.length; i++) {
      bookList.add(Book(
          data[i]['volumeInfo']['authors'],
          data[i]['volumeInfo']['categories'],
          data[i]['volumeInfo']['description'],
          data[i]['volumeInfo']['pageCount'],
          data[i]['volumeInfo']['publishedDate'],
          data[i]['volumeInfo']['publisher'],
          data[i]['volumeInfo']['imageLinks']['thumbnail'],
          data[i]['volumeInfo']['title']));
    }
  } else {
    throw Exception('Failed to load books from API');
  }

  return bookList;
}

class Book {
  final List authors;
  final List categories;
  final String description;
  final int pageCount;
  final String publishedDate;
  final String publisher;
  final String thumbnail;
  final String title;
  String registerUser;
  String review;
  double rating = 0.0;

  Book(this.authors, this.categories, this.description, this.pageCount,
      this.publishedDate, this.publisher, this.thumbnail, this.title,
      {this.registerUser, this.review, this.rating});
}

class SpaceBox extends SizedBox {
  SpaceBox({double width = 8, double height = 8})
      : super(width: width, height: height);

  SpaceBox.width([double value = 8]) : super(width: value);

  SpaceBox.height([double value = 8]) : super(height: value);
}

// Firestore登録用関数
void setData(String collection, Map data) {
  Firestore.instance.collection(collection).document().setData(data);
}
