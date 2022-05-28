import 'package:flutter/material.dart';
import 'curd.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:async';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  String _username = "";
  Dbconnect dbObj = new Dbconnect();

  @override
  void initState() {
    // SharedPreferences.setMockInitialValues({});

    super.initState();
  }

  Widget startapp() {
    new Timer(const Duration(seconds: 2), () {
      _loadUserInfo();
    });
  }

  _loadUserInfo() async {
    dbObj.createDatabase().then((value) {
      Future<Map> result = dbObj.getAuthUser();
      result.then((value) {
        print(value);
        if (value['status']) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/home', ModalRoute.withName('/home'));
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', ModalRoute.withName('/login'));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Color(0xff284243),
      duration: 3000,
      splash: 'assets/icon.png',
      nextScreen: Scaffold(
        body: startapp(),
        backgroundColor: Color(0xff284243),
      ),
      splashTransition: SplashTransition.sizeTransition,
      pageTransitionType: PageTransitionType.size,
    );
  }
}
