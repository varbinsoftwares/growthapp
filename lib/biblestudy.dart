import 'package:flutter/material.dart';
import 'curd.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BibleStudyPage extends StatefulWidget {
  const BibleStudyPage({Key key}) : super(key: key);
  @override
  _Biblestudy createState() => _Biblestudy();
}

class _Biblestudy extends State<BibleStudyPage>
    with AutomaticKeepAliveClientMixin<BibleStudyPage> {
  String selectedbutton = "A";
  Dbconnect dbObj = new Dbconnect();

  var listData = [];
  var listDataFinal = [];
  bool loadingdata = false;
  int progesspercent = 0;
  bool startloading = false;
  TextEditingController searchText = new TextEditingController();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    dbObj.createDatabase().then((value) {
      getAllData("A");
      getBibleStudydata();
    });

    super.initState();
  }

  Future<int> insertBibleStudyData(bibleobjlist, int index) async {
    var bibleobj = bibleobjlist[index];
    print(bibleobj['server_id']);
    if (bibleobjlist.length > index + 1) {
      setState(() {
        startloading = true;
      });
      await dbObj
          .insertDataBibleStudy(
              body: bibleobj['body'],
              char: bibleobj['char'],
              serverid: bibleobj['server_id'],
              title: bibleobj['title'])
          .then((value) {
        int perdata = bibleobjlist.length;
        setState(() {
          progesspercent = ((index * 100) / perdata).round();
        });
        var percent = ((index * 100) / perdata).round();
        print(percent);
        insertBibleStudyData(bibleobjlist, index + 1);
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

  getBibleStudydata() async {
    setState(() {
      startloading = true;
    });
    var url =
        'https://growth.christianappdevelopers.com/index.php/MobileApi/getBibleStudyData2';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      int totaldata = jsonResponse.length;
      print("checkdata");
      dbObj.getDataBibleStudyCount().then((value) {
        print(value);
        var totalcounteddata = value[0]['total'];
        if (totalcounteddata == 0) {
          print("no data here nedd to download");
          insertBibleStudyData(jsonResponse, 0).then((value) {
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

  getAllData(String char) {
    setState(() {
      loadingdata = false;
    });
    dbObj.getDataBibleStudy(char).then((value) {
      setState(() {
        listData = value;
        listDataFinal = value;
        loadingdata = true;
      });
    });
  }

  openDetailsWindow(listobj, displayKey) async {
    var detailpage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(listobj, displayKey)),
    );
    print("======================");
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
              key: PageStorageKey("Bible"),
              itemBuilder: (context, itemIndex) {
                return Container(
                  height: 70,
                  key: PageStorageKey("bible"),
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
          !startloading
              ? Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: TextField(
                      // obscureText: true,
                      controller: searchText,
                      decoration: InputDecoration(
                        //border: OutlineInputBorder(),
                        hintText: 'Search',
                      ),
                      onChanged: (returnvalue) {
                        print(returnvalue);
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
                      }),
                )
              : SizedBox(
                  height: 0,
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

  openEditWindow() async {}

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
                widget.tableId.containsKey('title') == false
                    ? new Row(
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
                                  side:
                                      BorderSide(width: 2.0, color: Colors.red),
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
                                  side:
                                      BorderSide(width: 2.0, color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32.0),
                                  ),
                                ),
                              )),
                        ],
                      )
                    : Divider(
                        height: 0,
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
