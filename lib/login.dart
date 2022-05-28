import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'curd.dart';
import 'package:email_validator/email_validator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);
  @override
  _Login createState() => _Login();
}

class _Login extends State<LoginPage> {
  Dbconnect dbObj = new Dbconnect();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _name = new TextEditingController();
  String emails = "rani21rathore@gmail.com";
  String pass = "12345";
  bool loadingindicator = false;

  @override
  Future<String> _loginCheck(email, name) async {
    setState(() {
      loadingindicator = true;
    });
    var jsonbody = {'name': name.text, 'email': email.text};
    var url =
        'https://growth.christianappdevelopers.com/index.php/MobileApi/registrationMob';
    var response = await http.post(url, body: jsonbody);
    var datas = response.body;
    var userdata = jsonDecode(datas);
    var allDatas = userdata['userdata'];
    if (response.statusCode == 200) {
      setState(() {
        loadingindicator = false;
      });
    }
    dbObj.insertAuthUser(
      user_id: allDatas['id'],
      name: allDatas['name'],
      email: allDatas['email'],
    );
    Navigator.pushNamedAndRemoveUntil(
        context, '/home', ModalRoute.withName('/home'));
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.white,
      ),
      home: Scaffold(
        backgroundColor: Color(0xff284243),
        body: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Center(
                      child: Container(
                        width: 200,
                        height: 150,
                        /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                        child: Image.asset('assets/icon.png'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15, bottom: 10),
                    //padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      controller: _name,
                      style: TextStyle(color: Colors.white),
                      
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter Your Name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelStyle:TextStyle(color: Colors.white60),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(),
                        labelText: 'Name',
                        hintText: 'Enter name',
                      ),
                    ),
                  ),
                  Padding(
                    //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: _email,
                      style: TextStyle(color: Colors.white),
                      validator: (value) {
                        bool checkemail = EmailValidator.validate(value);
                        if (!checkemail) {
                          return "Please enter valid email address";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelStyle:TextStyle(color: Colors.white60),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          hintText: 'Enter valid email id as abc@gmail.com',
                          fillColor: Colors.white),
                    ),
                  ),
                  Divider(
                    height: 20,
                  ),
                  Container(
                      height: 50,
                      width: 250,
                      child: RaisedButton.icon(
                        icon: Container(
                            child: loadingindicator
                                ? Container(
                                    child: CircularProgressIndicator(),
                                    height: 20,
                                    width: 20,
                                  )
                                : Icon(Icons.verified_user_outlined)),
                        label: loadingindicator
                            ? Text("Checking...")
                            : Text("Login"),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _loginCheck(_email, _name);
                          }
                        },
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
