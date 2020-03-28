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
  List<Book> bookList = [];

  final myController = TextEditingController();

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
                              setState(() {
//                                bookList = [];
                                buildItemList(bookList, myController.text);
                                WidgetsBinding.instance.addPostFrameCallback(
                                        (_) => myController.clear());
                              });
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
                  child: (bookList == null || bookList.length == 0)
                      ? Text("Book List is displayed here!")
                      : ListView.builder(
                    // TODO: GestureDetectorが一部のアイテムにしか効いていない
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () =>
                              showCustomDialogWithImage(
                                  context,
                                  bookList[index].authors,
                                  bookList[index].categories,
                                  bookList[index].description,
                                  bookList[index].pageCount,
                                  bookList[index].publishedDate,
                                  bookList[index].publisher,
                                  bookList[index].thumbnail,
                                  bookList[index].title),
                          child: Card(
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
                            ),
                          ),
                        );
                      },
                      itemCount: bookList.length)),
            )
          ],
        ),
      ),
    );
  }

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
//                  onPressed: () {
//                    Navigator.of(context)
//                        .push(MaterialPageRoute(builder: (context) {
//                      return Overlay(
//                        initialEntries: [
//                          OverlayEntry(builder: (context) {
//                            return FlashPage();
//                          }),
//                        ],
//                      );
//                    }));
//                  }

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

    showDialog(
        context: context, builder: (BuildContext context) => dialogWithImage);
  }
}

Future<List<Book>> buildItemList(List<Book> bookList, String input) async {
  String baseUrl = 'https://www.googleapis.com/books/v1/volumes?q=';
  String getUrl = baseUrl + input;

  final response = await http.get(getUrl);

  if (response.statusCode == 200) {
    bookList.clear();
    Map<String, dynamic> map = json.decode(response.body);
    List<dynamic> data = map["items"];

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

  Book(this.authors, this.categories, this.description, this.pageCount,
      this.publishedDate, this.publisher, this.thumbnail, this.title);
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

// TODO: ダイアログ一覧:全ては不要のため、リファクタリング
class FlashPage extends StatefulWidget {
  @override
  _FlashPageState createState() => _FlashPageState();
}

class _FlashPageState extends State<FlashPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(true),
      child: Scaffold(
        key: _key,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text('Flash Demo'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          title: Text('Flash'),
                          content: Text(
                              '⚡️A highly customizable, powerful and easy-to-use alerting library for Flutter.'),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('YES'),
                            ),
                            FlatButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('NO'),
                            ),
                          ],
                        );
                      });
                })
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: AlwaysScrollableScrollPhysics(),
                child: Wrap(
                  spacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text('FlashBar'),
                      ],
                    ),
                    RaisedButton(
                      onPressed: () => _showBasicsFlash(),
                      child: Text('Basics'),
                    ),
                    RaisedButton(
                      onPressed: () =>
                          _showBasicsFlash(duration: Duration(seconds: 2)),
                      child: Text('Basics | Duration'),
                    ),
                    RaisedButton(
                      onPressed: () =>
                          _showBasicsFlash(flashStyle: FlashStyle.grounded),
                      child: Text('Basics | Grounded'),
                    ),
                    Row(children: <Widget>[]),
                    RaisedButton(
                      onPressed: () => _showTopFlash(),
                      child: Text('Top'),
                    ),
                    RaisedButton(
                      onPressed: () =>
                          _showTopFlash(style: FlashStyle.grounded),
                      child: Text('Top | Grounded'),
                    ),
                    Row(children: <Widget>[]),
                    RaisedButton(
                      onPressed: () => _showBottomFlash(),
                      child: Text('Bottom'),
                    ),
                    RaisedButton(
                      onPressed: () =>
                          _showBottomFlash(
                              margin: const EdgeInsets.only(
                                  left: 12.0, right: 12.0, bottom: 34.0)),
                      child: Text('Bottom | Margin'),
                    ),
                    RaisedButton(
                      onPressed: () => _showBottomFlash(persistent: false),
                      child: Text('Bottom | No Persistent'),
                    ),
                    Row(
                      children: <Widget>[
                        Text('FLash Input'),
                      ],
                    ),
                    RaisedButton(
                      onPressed: () => _showInputFlash(),
                      child: Text('Input'),
                    ),
                    RaisedButton(
                      onPressed: () =>
                          _showInputFlash(
                            persistent: false,
                            onWillPop: () => Future.value(true),
                          ),
                      child: Text('Input | No Persistent | Will Pop'),
                    ),
                    Row(
                      children: <Widget>[
                        Text('Flash Toast'),
                      ],
                    ),
                    RaisedButton(
                      onPressed: () =>
                          _showCenterFlash(
                              position: FlashPosition.top,
                              style: FlashStyle.floating),
                      child: Text('Top'),
                    ),
                    RaisedButton(
                      onPressed: () =>
                          _showCenterFlash(alignment: Alignment.center),
                      child: Text('Center'),
                    ),
                    RaisedButton(
                      onPressed: () =>
                          _showCenterFlash(
                              position: FlashPosition.bottom,
                              style: FlashStyle.floating),
                      child: Text('Bottom'),
                    ),
                    Row(
                      children: <Widget>[
                        Text('FLash Helper'),
                      ],
                    ),
                    RaisedButton(
                      onPressed: () =>
                          FlashHelper.toast(
                              'You can put any message of any length here.'),
                      child: Text('Toast'),
                    ),
                    RaisedButton(
                      onPressed: () =>
                          FlashHelper.successBar(context,
                              message: 'I succeeded!'),
                      child: Text('Success Bar'),
                    ),
                    RaisedButton(
                      onPressed: () =>
                          FlashHelper.informationBar(context,
                              message: 'Place information here!'),
                      child: Text('Information Bar'),
                    ),
                    RaisedButton(
                      onPressed: () =>
                          FlashHelper.errorBar(context,
                              message: 'Place error here!'),
                      child: Text('Error Bar'),
                    ),
                    RaisedButton(
                      onPressed: () =>
                          FlashHelper.actionBar(context,
                              message: 'Place error here!',
                              primaryAction: Text('Done'),
                              onPrimaryActionTap: (controller) =>
                                  controller.dismiss()),
                      child: Text('Action Bar'),
                    ),
                    RaisedButton(
                      onPressed: () => _showDialogFlash(),
                      child: Text('Simple Dialog'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        var completer = Completer();
                        Future.delayed(Duration(seconds: 5))
                            .then((_) => completer.complete());
                        FlashHelper.blockDialog(
                          context,
                          dismissCompleter: completer,
                        );
                      },
                      child: Text('Block Dialog'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Future.delayed(
                            Duration(seconds: 2), () => _showDialogFlash());
                      },
                      child: Text('Simple Dialog Delay'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        FlashHelper.inputDialog(context,
                            persistent: false,
                            title: 'Hello Flash',
                            message:
                            'You can put any message of any length here.')
                            .then((value) {
                          if (value != null) _showMessage(value);
                        });
                      },
                      child: Text('Input Dialog'),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(child: Container(), top: false),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => NextPage())),
          child: Icon(Icons.navigate_next),
        ),
      ),
    );
  }

  void _showBasicsFlash({
    Duration duration,
    flashStyle = FlashStyle.floating,
  }) {
    showFlash(
      context: context,
      duration: duration,
      builder: (context, controller) {
        return Flash(
          controller: controller,
          style: flashStyle,
          boxShadows: kElevationToShadow[4],
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            message: Text('This is a basic flash'),
          ),
        );
      },
    );
  }

  void _showTopFlash({FlashStyle style = FlashStyle.floating}) {
    showFlash(
      context: context,
      duration: const Duration(seconds: 2),
      persistent: false,
      builder: (_, controller) {
        return Flash(
          controller: controller,
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          boxShadows: [BoxShadow(blurRadius: 4)],
          barrierBlur: 3.0,
          barrierColor: Colors.black38,
          barrierDismissible: true,
          style: style,
          position: FlashPosition.top,
          child: FlashBar(
            title: Text('Title'),
            message: Text('Hello world!'),
            showProgressIndicator: true,
            primaryAction: FlatButton(
              onPressed: () => controller.dismiss(),
              child: Text('DISMISS', style: TextStyle(color: Colors.amber)),
            ),
          ),
        );
      },
    );
  }

  void _showBottomFlash(
      {bool persistent = true, EdgeInsets margin = EdgeInsets.zero}) {
    showFlash(
      context: context,
      persistent: persistent,
      builder: (_, controller) {
        return Flash(
          controller: controller,
          margin: margin,
          borderRadius: BorderRadius.circular(8.0),
          borderColor: Colors.blue,
          boxShadows: kElevationToShadow[8],
          backgroundGradient: RadialGradient(
            colors: [Colors.amber, Colors.black87],
            center: Alignment.topLeft,
            radius: 2,
          ),
          onTap: () => controller.dismiss(),
          forwardAnimationCurve: Curves.easeInCirc,
          reverseAnimationCurve: Curves.bounceIn,
          child: DefaultTextStyle(
            style: TextStyle(color: Colors.white),
            child: FlashBar(
              title: Text('Hello Flash'),
              message: Text('You can put any message of any length here.'),
              leftBarIndicatorColor: Colors.red,
              icon: Icon(Icons.info_outline),
              primaryAction: FlatButton(
                onPressed: () => controller.dismiss(),
                child: Text('DISMISS'),
              ),
              actions: <Widget>[
                FlatButton(
                    onPressed: () => controller.dismiss('Yes, I do!'),
                    child: Text('YES')),
                FlatButton(
                    onPressed: () => controller.dismiss('No, I do not!'),
                    child: Text('NO')),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (_ != null) {
        _showMessage(_.toString());
      }
    });
  }

  void _showInputFlash({
    bool persistent = true,
    WillPopCallback onWillPop,
  }) {
    var editingController = TextEditingController();
    showFlash(
      context: context,
      persistent: persistent,
      onWillPop: onWillPop,
      builder: (_, controller) {
        return Flash.bar(
          controller: controller,
          barrierColor: Colors.black54,
          borderWidth: 3,
          style: FlashStyle.grounded,
          forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
          child: FlashBar(
            title: Text('Hello Flash', style: TextStyle(fontSize: 24.0)),
            message: Text('You can put any message of any length here.'),
            userInputForm: Form(
              child: TextFormField(
                controller: editingController,
                autofocus: true,
              ),
            ),
            leftBarIndicatorColor: Colors.red,
            primaryAction: IconButton(
              onPressed: () {
                if (editingController.text.isEmpty) {
                  controller.dismiss();
                } else {
                  var message = editingController.text;
                  _showMessage(message);
                  editingController.text = '';
                }
              },
              icon: Icon(Icons.send, color: Colors.amber),
            ),
          ),
        );
      },
    );
  }

  void _showCenterFlash({
    FlashPosition position,
    FlashStyle style,
    Alignment alignment,
  }) {
    showFlash(
      context: context,
      duration: Duration(seconds: 5),
      builder: (_, controller) {
        return Flash(
          controller: controller,
          backgroundColor: Colors.black87,
          borderRadius: BorderRadius.circular(8.0),
          borderColor: Colors.blue,
          position: position,
          style: style,
          alignment: alignment,
          enableDrag: false,
          onTap: () => controller.dismiss(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: DefaultTextStyle(
              style: TextStyle(color: Colors.white),
              child: Text(
                'You can put any message of any length here.',
              ),
            ),
          ),
        );
      },
    ).then((_) {
      if (_ != null) {
        _showMessage(_.toString());
      }
    });
  }

  void _showDialogFlash() {
    FlashHelper.simpleDialog(context,
        title: 'Flash Dialog',
        message:
        '⚡️A highly customizable, powerful and easy-to-use alerting library for Flutter.',
        negativeAction: Text('NO'),
        negativeActionTap: (controller) => controller.dismiss(),
        positiveAction: Text('YES'),
        positiveActionTap: (controller) => controller.dismiss());
  }

  void _showMessage(String message) {
    if (!mounted) return;
    showFlash(
        context: context,
        duration: Duration(seconds: 3),
        builder: (_, controller) {
          return Flash(
            controller: controller,
            position: FlashPosition.top,
            style: FlashStyle.grounded,
            child: FlashBar(
              icon: Icon(
                Icons.face,
                size: 36.0,
                color: Colors.black,
              ),
              message: Text(message),
            ),
          );
        });
  }
}

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(color: Colors.blueGrey),
    );
  }
}
