import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_advanced_networkimage/provider.dart';

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
                              setState(() {
                                buildItemList(bookList, myController.text);
                                myController.clear();
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
                      ? Text("Loading....")
                      : ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
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
}

RegisterBooks() {
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

Future<List<Book>> buildItemList(List<Book> bookList, String input) async {
//  final baseUrl = 'https://www.googleapis.com/books/v1/volumes?';
  String baseUrl = 'https://www.googleapis.com/books/v1/volumes?q=';
  String getUrl = baseUrl + input;

  final response = await http.get(getUrl);

  if (response.statusCode == 200) {
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
