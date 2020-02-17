import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
    home: new MyApp(), // becomes the route named '/'
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ブックレンタルアプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ブックレンタルアプリ'),
	    routes: <String, WidgetBuilder>{
		    '/book_detail': (BuildContext context) => new BookDetail(),
	    },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // TODO: グループIDで登録されている本の一覧をDBから取得し、そのレコード数をCardの要素数とする
  static int length = 30;
  var cardlist = List.generate(length, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GridView.count(
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
//          Card(
//            child: new InkWell(
////              onTap: () {
////                Navigator.of(context).pushNamed('/b');
////              },
//              child: Container(
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    AspectRatio(
//                      aspectRatio: 18.0 / 11.0,
//                      child: Image.asset(
//                          'assets/f_f_object_174_s128_f_object_174_1bg.png'),
//                    ),
//                    Padding(
//                      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          Text('Title'),
//                          SizedBox(height: 8.0),
//                          Text('Secondry Text'),
//                        ],
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//            ),
//          ),
          Card()
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
