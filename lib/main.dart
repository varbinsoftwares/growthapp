import 'package:flutter/material.dart';
import 'biblestudy.dart';
import 'personalnote.dart';
import 'scriptures.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'curd.dart';
import 'loading.dart';
import 'login.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Words Of Life Collection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: MyHomePage(title: 'Growth App'),
      routes: {
        '/': (context) => Landing(),
        '/home': (context) => MyHomePage(),
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
  //ScaffoldSetPage listObj = new ScaffoldSetPage();
  Dbconnect dbObj = new Dbconnect();


  deleteUserData() {
    dbObj.deleteUserData().then((value) {
      Navigator.pushNamedAndRemoveUntil(
          context, '/login', ModalRoute.withName('/login'));
    });
  }

 
  TabController _tabController;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      // getBibleStudydata();
    });

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<int, Color> color = {
    50: Color.fromRGBO(136, 14, 79, .1),
    100: Color.fromRGBO(136, 14, 79, .2),
    200: Color.fromRGBO(136, 14, 79, .3),
    300: Color.fromRGBO(136, 14, 79, .4),
    400: Color.fromRGBO(136, 14, 79, .5),
    500: Color.fromRGBO(136, 14, 79, .6),
    600: Color.fromRGBO(136, 14, 79, .7),
    700: Color.fromRGBO(136, 14, 79, .8),
    800: Color.fromRGBO(136, 14, 79, .9),
    900: Color.fromRGBO(136, 14, 79, 1),
  };

  void _showDialog(contaxtpr) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Please Confirm"),
          content:
              new Text("Are you sure want to logout ? Data will be lost ."),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes Sure"),
              onPressed: () {
                // dbObj.deleteData(widget.tableId['id']);
                deleteUserData();
                Navigator.pop(context, "pop");
                Navigator.pop(contaxtpr, "pop");
              },
            ),
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Color(0xff284243),
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: "Bible Study",
                  icon: Opacity(
                      opacity: 1,
                      child: Opacity(
                          opacity: 0.5,
                          child: Image.asset(
                            'assets/bible.png',
                            height: 30,
                          ))),
                ),
                Tab(
                  text: "Personal Notes",
                  icon: Image.asset(
                    'assets/bible_study.png',
                    height: 30,
                  ),
                ),
                Tab(
                    text: "Memorize Scriptures",
                    icon: Image.asset(
                      'assets/notes.png',
                      height: 30,
                    )),
              ],
            ),
            title: Text('Growth'),
            actions: <Widget>[
             
              FlatButton(
                textColor: Colors.white,
                onPressed: () {
                  _showDialog(context);

                  // deleteUserData();
                },
                child: Row(children: [Icon(Icons.logout)]),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              BibleStudyPage(),
              PersonalNotePage(),
              MemorizeScriptPage(),
            ],
          ),
        ),
      ),
    );
    
  }

 
}
