//import 'package:carousel_controller.dart';
//import 'package:carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'curd.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MemorizeScriptPage extends StatefulWidget {
  const MemorizeScriptPage({Key key}) : super(key: key);
  @override
  _MemorizeScript createState() => _MemorizeScript();
}

class _MemorizeScript extends State<MemorizeScriptPage>
    with AutomaticKeepAliveClientMixin<MemorizeScriptPage> {
  Dbconnect dbObj = new Dbconnect();
  String selectedbutton = "A";
  var listData = [];
  var listDataFinal = [];
  bool loadingdata = false;
  double fontsize = 15;
  int currentpage = 0;
  Map userdata = {};
  int progesspercent = 0;
  bool startloading = false;

  CarouselController buttonCarouselController = CarouselController();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    dbObj.createDatabase().then((value) {
      dbObj.getAuthUser().then((value) {
        print(value);
        setState(() {
          userdata = value['userdata'];
          getAllData();
          getScripturesdata(userdata['user_id']);
        });
      });
    });

    super.initState();
  }

  Future<int> insertScriptureData(bibleobjlist, int index) async {
    var bibleobj = bibleobjlist[index];
    print(bibleobj['server_id']);
    if (bibleobjlist.length > index + 1) {
      setState(() {
        startloading = true;
      });
      await dbObj
          .insertDataScriptureBulk(
              body: bibleobj['body'],
              serverid: bibleobj['server_id'],
              userid: userdata['user_id'])
          .then((value) {
        int perdata = bibleobjlist.length;
        setState(() {
          progesspercent = ((index * 100) / perdata).round();
        });
        var percent = ((index * 100) / perdata).round();
        print(percent);
        insertScriptureData(bibleobjlist, index + 1);
        return index + 1;
      });
    } else {
      setState(() {
        getAllData();
        startloading = false;
      });
      return 100;
    }
    return index + 1;
  }

  getScripturesdata(String userid) async {
    setState(() {
      startloading = true;
    });
    var url =
        'https://growth.christianappdevelopers.com/index.php/MobileApi/getUserSyncData/' +
            userid;
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body)['scriptures'];
      int totaldata = jsonResponse.length;
      print("$totaldata checkdata");
      dbObj.getDataScriptsCount().then((value) {
        print(value);
        var totalcounteddata = value[0]['total'];
        if (totalcounteddata == 0) {
          print("no data here nedd to download");
          insertScriptureData(jsonResponse, 0).then((value) {
            setState(() {
              startloading = false;
            });
          });
        } else {
          print("Data Synced");
          if (totalcounteddata < totaldata) {
            setState(() {
              startloading = false;
            });
          }
        }
      });
    }
  }

  getAllData() {
    setState(() {
      loadingdata = false;
    });
    dbObj.getDataScript().then((value) {
      print("-------------");
      print(value);
      setState(() {
        listData = value;
        listDataFinal = value;
        loadingdata = true;
      });
    });
  }

  openEditPage() async {
    print(listData[currentpage]);

    int navigationresult = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditScriptPage(
              editabledata: listData[currentpage],
              contextpr: context,
              currentpage: currentpage)),
    );
    getAllData();
    FocusScope.of(context).requestFocus(FocusNode());

    if (navigationresult != null) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        buttonCarouselController.jumpToPage(navigationresult);
      });
    }
  }

  openCreateWindows() async {
    final navigationresult = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateScriptPage(selectedbutton)),
    );
    getAllData();
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey,
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[400],
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 200,

              // padding: EdgeInsets.all(10.0),
              child: new Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      width: 70,
                      padding: EdgeInsets.all(10.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          buttonCarouselController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.linear);
                        },
                        color: Colors.red,
                      )),
                  Container(
                      width: 80,
                      padding: EdgeInsets.all(10.0),
                      child: IconButton(
                        icon: Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: () {
                          buttonCarouselController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.linear);
                        },
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(32.0),
                        // ),
                        color: Colors.red,
                      )),
                ],
              ),
            ),
            Container(
              width: 140,
              padding: EdgeInsets.all(10.0),
              child: RaisedButton.icon(
                label: Text("Add New", style: TextStyle(color: Colors.white)),
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  openCreateWindows();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          listData.length > 0
              ? ButtonBar(
                  buttonHeight: 30,
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Small'),
                      color: fontsize == 15 ? Colors.red : Colors.grey[600],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red)),
                      onPressed: () {
                        setState(() {
                          fontsize = 15;
                        });
                      },
                    ),
                    FlatButton(
                      child: Text('Medium'),
                      color: fontsize == 20 ? Colors.red : Colors.grey[600],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red)),
                      onPressed: () {
                        setState(() {
                          fontsize = 20;
                        });
                      },
                    ),
                    FlatButton(
                      child: Text('Large'),
                      color: fontsize == 25 ? Colors.red : Colors.grey[600],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red)),
                      onPressed: () {
                        setState(() {
                          fontsize = 25;
                        });
                      },
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    RaisedButton.icon(
                      label:
                          Text("Edit", style: TextStyle(color: Colors.white)),
                      icon: Icon(Icons.edit_outlined, color: Colors.white),
                      onPressed: () {
                        openEditPage();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                      color: Colors.red,
                    ),
                  ],
                )
              : Center(
                  child: Container(
                    padding: EdgeInsets.only(top: 50),
                    child: Text("No Data Found"),
                  ),
                ),
          startloading
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [Text("$progesspercent% loading..")],
                  ),
                  // child: CircularProgressIndicator(),
                )
              : SizedBox(
                  width: 50,
                  height: 0,
                ),
          loadingdata
              ? CarouselSlider(
                  items: new List.generate(
                      listData.length,
                      (index) => Container(
                            width: double.infinity,
                            child: Card(
                              // color: Colors.black,
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                child: SingleChildScrollView(
                                  child: Text(
                                    listData[index]['body'],
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: fontsize),
                                  ),
                                ),
                              ),
                            ),
                          )),
                  carouselController: buttonCarouselController,
                  options: CarouselOptions(
                    height: 400,
                    autoPlay: false,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                    aspectRatio: 2.0,
                    initialPage: 0,
                    onPageChanged: (page, reason) {
                      print(page);
                      setState(() {
                        currentpage = page;
                      });
                    },
                  ),
                )
              : Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class CreateScriptPage extends StatefulWidget {
  //const CreateScriptPage({Key key}) : super(key: key);
  String selectedAlpha;
  Function(String) onPressed;

  CreateScriptPage(String selectedAlpha) {
    this.selectedAlpha = selectedAlpha;
  }
  @override
  _CreateScript createState() => _CreateScript();
}

class _CreateScript extends State<CreateScriptPage>
    with AutomaticKeepAliveClientMixin<CreateScriptPage> {
  Map userdata = {};
  final _formKey = GlobalKey<FormState>();
  Dbconnect dbObj = new Dbconnect();

  @override
  void initState() {
    dbObj.createDatabase().then((value) {
      dbObj.getAuthUser().then((value) {
        setState(() {
          userdata = value['userdata'];
        });
      });
    });
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  final TextEditingController _crateNoteController =
      new TextEditingController();

  void _CreateScriptData(datas, alpha) {
    var body = datas.text;
    var char = alpha;

    dbObj.insertDataScripture(
        body: body, serverid: "", userid: userdata['user_id']);
    Navigator.pop(context, "pop");
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Create Note"),
        actions: [
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _CreateScriptData(_crateNoteController, widget.selectedAlpha);
              }
            },
            child: Text("Save"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              child: Container(
                padding: EdgeInsets.all(20),
                constraints: BoxConstraints(maxHeight: 350),
                child: new SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  child: TextFormField(
                    decoration: new InputDecoration(hintText: 'Type here'),
                    style: TextStyle(),
                    controller: _crateNoteController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    autofocus: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditScriptPage extends StatefulWidget {
  @override
  Map editabledata;
  var contextpr;
  int currentpage;
  EditScriptPage({this.editabledata, this.contextpr, this.currentpage});
  _EditScript createState() => _EditScript();
}

class _EditScript extends State<EditScriptPage> {
  Dbconnect dbObj = new Dbconnect();

  final _formKey = GlobalKey<FormState>();
  //TextEditingController edata = new TextEditingController();
  final TextEditingController _textController = new TextEditingController();

  void _updateData(ids, datas, server_id) {
    dbObj.updateDataScript(ids, datas, server_id);
    Navigator.pop(widget.contextpr, widget.currentpage);
  }

  void _showDialog(contaxtpr) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Please Confirm"),
          content: new Text("Are you sure to delete this script?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes Sure"),
              onPressed: () {
                dbObj.deleteDataScript(widget.editabledata['id'],
                    widget.editabledata['server_id']);
                Navigator.pop(context, "pop");
                Navigator.pop(contaxtpr, widget.currentpage - 1);
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
    _textController.text = widget.editabledata['body'];
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Edit"),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              _showDialog(context);
            },
            child: Row(
              children: [Icon(Icons.delete), Text("Delete")],
            ),
          ),
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              _updateData(widget.editabledata['id'], _textController.text,
                  widget.editabledata['server_id']);
            },
            child: Row(
              children: [Icon(Icons.save), Text("Save")],
            ),
          ),
        ],
        // leading: new Container(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(maxHeight: 350),
                child: new SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  child: TextFormField(
                    style: TextStyle(),
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 15,
                    autofocus: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
