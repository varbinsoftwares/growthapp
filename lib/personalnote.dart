import 'package:flutter/material.dart';
import 'curd.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonalNotePage extends StatefulWidget {
  const PersonalNotePage({Key key}) : super(key: key);
  @override
  PersonalNote createState() => PersonalNote();
}

class PersonalNote extends State<PersonalNotePage>
    with AutomaticKeepAliveClientMixin<PersonalNotePage> {
  Dbconnect dbObj = new Dbconnect();
  String selectedbutton = "A";
  var listData = [];
  var listDataFinal = [];
  bool loadingdata = false;
  Map userdata = {};

  int progesspercent = 0;
  bool startloading = false;
  TextEditingController searchText = new TextEditingController();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    dbObj.createDatabase().then((value) {
      dbObj.getAuthUser().then((value) {
        setState(() {
          userdata = value['userdata'];

          getAllData("A");
          getPersonalNotedata(userdata['user_id']);
        });
      });
    });
    super.initState();
  }

  Future<int> insertPersonalNoteData(bibleobjlist, int index) async {
    var bibleobj = bibleobjlist[index];

    if (bibleobjlist.length > index + 1) {
      setState(() {
        startloading = true;
      });
      await dbObj
          .insertDataBulk(
              title: bibleobj['title'],
              body: bibleobj['body'],
              chars: bibleobj['char'],
              serverid: bibleobj['server_id'],
              userid: userdata['user_id'])
          .then((value) {
        int perdata = bibleobjlist.length;
        setState(() {
          progesspercent = ((index * 100) / perdata).round();
        });
        var percent = ((index * 100) / perdata).round();

        insertPersonalNoteData(bibleobjlist, index + 1);
        return index + 1;
      });
    } else {
      setState(() {
        getAllData(selectedbutton);
        startloading = false;
      });
      return 100;
    }
    return index + 1;
  }

  getPersonalNotedata(String userid) async {
    // setState(() {
    //   startloading = true;
    // });
    var url =
        'https://growth.christianappdevelopers.com/index.php/MobileApi/getUserSyncData/' +
            userid;
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body)['notes'];
      int totaldata = jsonResponse.length;
      print("$totaldata checkdata");
      dbObj.getDataPersonalNotesCount().then((value) {
        print(value);
        var totalcounteddata = value[0]['total'];
        if (totalcounteddata == 0) {
          print("no data here nedd to download");
          insertPersonalNoteData(jsonResponse, 0).then((value) {
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

  //get list data function
  getAllData(String char) {
    setState(() {
      loadingdata = false;
    });
    dbObj.getData(char).then((value) {
      setState(() {
        listData = value;
        listDataFinal = value;
        loadingdata = true;
      });
    });
  }

  openCreateWindows() async {
    final navigationresult = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateNotesPage(selectedbutton)),
    );
    // if (navigationresult != null) {
    getAllData(selectedbutton);
    // }
    FocusScope.of(context).requestFocus(FocusNode());
  }

  openDetailsWindow(listobj, displayKey) async {
    var detailpage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(listobj, displayKey)),
    );

    getAllData(selectedbutton);
  }

  final List<String> elements = [
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
  ];
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 80,
            color: Colors.grey[300],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: elements.length,
              key: PageStorageKey("Note"),
              itemBuilder: (context, itemIndex) {
                return Container(
                  height: 70,
                  width: 70,
                  padding: const EdgeInsets.only(left: 16.0),
                  child: RaisedButton(
                    elevation: 5,
                    shape: CircleBorder(),
                    //color: Colors.white,
                    color: selectedbutton == elements[itemIndex]
                        ? Colors.red
                        : Colors.white,

                    child: Text(elements[itemIndex],
                        style: TextStyle(
                            fontSize: 25,
                            color: selectedbutton == elements[itemIndex]
                                ? Colors.white
                                : Colors.red)),
                    onPressed: () {
                      setState(() {
                        selectedbutton = elements[itemIndex];
                        getAllData(selectedbutton);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          startloading
              ? Container(
                  padding: EdgeInsets.all(50),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 20,
                      ),
                      Text("$progesspercent% loading..")
                    ],
                  ),
                  // child: CircularProgressIndicator(),
                )
              : SizedBox(
                  height: 0,
                ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: TextField(
              // obscureText: true,
              controller: searchText,
              autofocus: false,

              decoration: InputDecoration(
                //border: OutlineInputBorder(),
                hintText: 'Search',
              ),
              onChanged: (returnvalue) {
                setState(() {
                  listData = listDataFinal;
                });
                // listData = listDataFinal;
                List searchlist = [];
                listData.forEach((item) {
                  if (item['title'].contains(returnvalue)) {
                    searchlist.add(item);
                  }
                });
                setState(() {
                  listData = searchlist;
                });
              },
            ),
          ),
          Flexible(
            // child: ScaffoldSetPage('notes', selectetdButton),
            child: loadingdata
                ? ListView.separated(
                    scrollDirection: Axis.vertical,
                    itemCount: listData.length,
                    key: PageStorageKey("study"),
                    itemBuilder: (context, itemIndex) {
                      return Container(
                        height: 50,
                        // width: 80,
                        // padding: const EdgeInsets.only(left: 10.0, bottom:10),
                        child: ListTile(
                          title: Text(
                            listData[itemIndex]["title"],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            softWrap: true,
                          ),
                          onTap: () {
                            openDetailsWindow(listData[itemIndex], "body");
                          },
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        height: 0,
                      );
                    },
                  )
                : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: () {
          openCreateWindows();
        },
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  Map tableId;
  String displaykey;
  DetailPage(Map tableId, String displaykey) {
    this.tableId = tableId;
    this.displaykey = displaykey;
  }

  @override
  _ButtonBarSet createState() => _ButtonBarSet();
}

class _ButtonBarSet extends State<DetailPage> {
  double fontsize = 15;
  Dbconnect dbObj = new Dbconnect();
  String editdatatext = "";

  openEditWindow() async {
    var body = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              EditNotePage(editabledata: widget.tableId, contextpr: context)),
    );
    if (body != null) {
      Navigator.pop(context);
    }
  }

  void _showDialog(contaxtpr) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Please Confirm"),
          content: new Text("Are you sure to delete this note?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes Sure"),
              onPressed: () {
                dbObj.deleteData(
                    widget.tableId['id'], widget.tableId['server_id']);
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
    editdatatext = widget.tableId['body'];
    return new Scaffold(
      appBar: new AppBar(
        title: Text(
          editdatatext,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        // title: new Text("kkkk"),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
        // leading: new Container(),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          width: double.infinity,
          child: Card(
            child: Column(
              children: [
                new ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Small'),
                      color: fontsize == 15 ? Colors.red : Colors.white12,
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
                      color: fontsize == 20 ? Colors.red : Colors.white12,
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
                      color: fontsize == 25 ? Colors.red : Colors.white12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red)),
                      onPressed: () {
                        setState(() {
                          fontsize = 25;
                        });
                      },
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.tableId.containsKey('title')
                          ? Text(widget.tableId['title'],
                              style: TextStyle(
                                  fontSize: fontsize,
                                  fontWeight: FontWeight.w900))
                          : Text(""),
                      widget.tableId.containsKey('title')
                          ? Divider(
                              height: 20,
                            )
                          : Text(""),
                      Text(widget.tableId['body'],
                          style: TextStyle(fontSize: fontsize)),
                    ],
                  ),
                ),
                new Row(
                  // alignment: MainAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(10.0),
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.edit),
                          label: Text("Edit"),
                          onPressed: () {
                            openEditWindow();
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(width: 2.0, color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                        )),
                    Container(
                        padding: EdgeInsets.all(10.0),
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.delete),
                          label: Text("Delete"),
                          onPressed: () {
                            _showDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(width: 2.0, color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                        )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EditNotePage extends StatefulWidget {
  @override
  Map editabledata;
  var contextpr;
  EditNotePage({this.editabledata, this.contextpr});
  _Editnote createState() => _Editnote();
}

class _Editnote extends State<EditNotePage> {
  Dbconnect dbObj = new Dbconnect();

  final _formKey = GlobalKey<FormState>();
  //TextEditingController edata = new TextEditingController();
  final TextEditingController _textController = new TextEditingController();
  final TextEditingController _textTitleController =
      new TextEditingController();

  void _updateData(ids, datas, title, server_id) {
    dbObj.updateData(ids, datas, title, server_id);

    Navigator.pop(widget.contextpr, datas);
  }

  @override
  Widget build(BuildContext context) {
    _textController.text = widget.editabledata['body'];
    _textTitleController.text = widget.editabledata['title'];
    return new Scaffold(
      appBar: new AppBar(
        title: Text("Edit"),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              print(widget.editabledata);
              _updateData(widget.editabledata['id'], _textController.text,
                  _textTitleController.text, widget.editabledata['server_id']);
            },
            child: Text("Save"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
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
                constraints: BoxConstraints(maxHeight: 80),
                child: new SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  child: TextFormField(
                    style: TextStyle(),
                    controller: _textTitleController,
                    keyboardType: TextInputType.text,
                    maxLines: 2,
                    autofocus: true,
                  ),
                ),
              ),
              Container(
                constraints: BoxConstraints(maxHeight: 350),
                child: new SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  child: TextFormField(
                    style: TextStyle(),
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
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

class CreateNotesPage extends StatefulWidget {
  //const CreateNotesPage({Key key}) : super(key: key);
  String selectedAlpha;
  Function(String) onPressed;

  CreateNotesPage(String selectedAlpha) {
    this.selectedAlpha = selectedAlpha;
  }
  @override
  _Createnote createState() => _Createnote();
}

class _Createnote extends State<CreateNotesPage> {
  final _formKey = GlobalKey<FormState>();
  Dbconnect dbObj = new Dbconnect();
  Map userdata = {};

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

  final TextEditingController _crateNoteController =
      new TextEditingController();
  final TextEditingController _crateNoteTitleController =
      new TextEditingController();

  void _createNoteData(datas, alpha, title) async {
    var body = datas.text;
    var char = alpha;

    dbObj.insertData(
        chars: char,
        body: body,
        title: title.text,
        serverid: "",
        userid: userdata['user_id']);

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
                _createNoteData(_crateNoteController, widget.selectedAlpha,
                    _crateNoteTitleController);
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
                padding: EdgeInsets.only(left: 20, right: 20),
                constraints: BoxConstraints(maxHeight: 80),
                child: new SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  reverse: true,
                  child: TextFormField(
                    decoration: new InputDecoration(hintText: 'Title...'),
                    style: TextStyle(),
                    controller: _crateNoteTitleController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                    autofocus: true,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(20),
                constraints: BoxConstraints(maxHeight: 250),
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
