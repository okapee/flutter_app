import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BooksearchAndRegistration extends StatelessWidget {
  BooksearchAndRegistration(
      {Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '書籍検索',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SearchAndRegistration(title: 'ブックレンタルアプリ', userId: this.userId));
  }
}

//MaterialApp(
////        title: 'ブックレンタルアプリ',
//theme: ThemeData(
//primarySwatch: Colors.blue,
//),
//home: MyHomePage(title: 'ブックレンタルアプリ', userId: this.userId),
//routes: <String, WidgetBuilder>{
//'/book_detail': (BuildContext context) => BookDetail(),
//'/booksearch_and_registration': (BuildContext context) =>
//BooksearchAndRegistration(),
//});

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
  List<String> itemList = [];

  final baseUrl = 'https://www.googleapis.com/books/v1/volumes?';

// Create a text controller and use it to retrieve the current value
// of the TextField.
  final myController = TextEditingController();

//  @override
//  void dispose() {
//    // Clean up the controller when the widget is disposed.
//    myController.dispose();
//    super.dispose();
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    flex: 8,
                    child: TextField(
                        // Now that you have a TextEditingController, wire it up to a text field using the controller property:
//                  controller: myController,
                        ),
                  ),
                  Expanded(
                    flex: 2,
                    child: FlatButton(
                      child: Text("検索"),
                      color: Colors.orange,
                      textColor: Colors.white,
                      onPressed: () {
                        return SearchBooks();
                      },
                    ),
                  ),
                ]),
            SpaceBox.height(10),
            Text('test'),
          ],
        ),
      ),
    );
  }
}

// TODO: 未実装
SearchBooks() {
  return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance.collection('test').snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return new Text('Loading...');
        default:
          return new ListView(
            children: snapshot.data.documents.map((DocumentSnapshot document) {
              return new ListTile(
                title: new Text(document['title']),
                subtitle: new Text(document['content']),
              );
            }).toList(),
          );
      }
    },
  );
}

class Book {
  final List<String> authors;
  final List<String> categories;
  final String description;
  final int pageCount;
  final String publishDate;
  final String publisher;
  final String thumbnail;
  final String title;

  Book(
      {this.authors,
      this.categories,
      this.description,
      this.pageCount,
      this.publishDate,
      this.publisher,
      this.thumbnail,
      this.title});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      authors: json['authors'],
      categories: json['categories'],
      description: json['description'],
      pageCount: json['pageCount'],
      publishDate: json['publishDate'],
      publisher: json['publisher'],
      thumbnail: json['thumbnail'],
      title: json['title'],
    );
  }
}

class SpaceBox extends SizedBox {
  SpaceBox({double width = 8, double height = 8})
      : super(width: width, height: height);

  SpaceBox.width([double value = 8]) : super(width: value);

  SpaceBox.height([double value = 8]) : super(height: value);
}
