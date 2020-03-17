import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BooksearchAndRegistration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '書籍検索',
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new SearchAndRegistration());
  }
}

class SearchAndRegistration extends StatefulWidget {
  SearchAndRegistration({Key key}) : super(key: key);

  _SearchAndRegistrationState createState() =>
      new _SearchAndRegistrationState();
}

class _SearchAndRegistrationState extends State<SearchAndRegistration> {
  List<String> itemList = [];

  final dio = new Dio();
  final baseUrl = 'https://www.googleapis.com/books/v1/volumes?';

  @override
  void initState() {
    buildItemList();
    super.initState();
  }

  void buildItemList() async {
    var response = await dio.get(baseUrl);
    for (int j = 0; j < response.data["items"].length; j++) {
      setState(() {
        itemList.add(response.data["items"][j]);
      });
    }
  }

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Row(children: <Widget>[
            TextField(
              // Now that you have a TextEditingController, wire it up to a text field using the controller property:
              controller: myController,
            ),
            RaisedButton(
              child: Text("Button"),
              color: Colors.orange,
              textColor: Colors.white,
              onPressed: () {
                return StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('test').snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return new Text('Loading...');
                      default:
                        return new ListView(
                          children: snapshot.data.documents
                              .map((DocumentSnapshot document) {
                            return new ListTile(
                              title: new Text(document['title']),
                              subtitle: new Text(document['content']),
                            );
                          }).toList(),
                        );
                    }
                  },
                );
              },
            ),
          ]),
        ],
      ),
    );
  }
}
