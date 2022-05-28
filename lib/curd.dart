import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dbconnect {
  Database db;

  Dbconnect() {
    createDatabase();
  }

  Future<String> createDatabase() async {
    print("create table ");
    db = await openDatabase('growthApp15.db', version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE  bible_study (id INTEGER PRIMARY KEY, body TEXT, title TEXT, char CHAR(10),server_id CHAR(10))');

      await db.execute(
          'CREATE TABLE  personal_note (id INTEGER PRIMARY KEY,  title TEXT, body TEXT,char CHAR(10),server_id CHAR(10),user_id CHAR(10))');
      await db.execute(
          'CREATE TABLE  scriptures (id INTEGER PRIMARY KEY, body TEXT,server_id CHAR(10),user_id CHAR(10))');
      await db.execute(
          'CREATE TABLE  auth_user (id INTEGER PRIMARY KEY, name CHAR(10),email CHAR(10),user_id CHAR(10))');
      return "ok";
    });
    return "ok";
  }

  Future<void> insertDataBulk({chars, body, title, serverid, userid}) async {
    print("=============================");
    int id2 = await db.rawInsert(
        'INSERT INTO personal_note(body,  char, title, server_id,user_id) VALUES(?,?,?,?,?)',
        [body, chars, title, serverid, userid]);
  }

  Future<void> insertData({chars, body, title, serverid, userid}) async {
    print("=============================");
    int id2 = await db.rawInsert(
        'INSERT INTO personal_note(body, char, title, server_id,user_id) VALUES(?,?,?,?, ?)',
        [body, chars, title, serverid, userid]);

    var jsonbody = {
      "body": body,
      "title": title,
      "char": chars,
      "datetime": "",
      "server_id": "",
      "table_name": "notes",
      "user_id": userid,
    };
    Map<String, String> header = {"Content-type": "application/json"};
    var url =
        'https://growth.christianappdevelopers.com/index.php/MobileApi/synctable';
    var response =
        await http.post(url, body: jsonEncode(jsonbody), headers: header);
    var datas = response.body;
    print(response.body);
    if (response.statusCode == 200) {
      var serverobj = jsonDecode(response.body);
      await db.rawUpdate('UPDATE personal_note SET server_id = ? WHERE id = ?',
          [serverobj['last_id'], id2]);
    }
  }

  Future<int> insertDataBibleStudy({char, body, title, serverid}) async {
    int id2 = await db.rawInsert(
        'INSERT INTO bible_study(body, char, title, server_id) VALUES(?,?,?, ?)',
        [body, char, title, serverid]);

    return id2;
  }

  Future<void> insertDataScriptureBulk({body, serverid, userid}) async {
    int id2 = await db.rawInsert(
        'INSERT INTO scriptures(body, server_id,user_id) VALUES(?, ?, ?)',
        [body, serverid, userid]);
  }

  Future<void> insertDataScripture({body, serverid, userid}) async {
    int id2 = await db.rawInsert(
        'INSERT INTO scriptures(body, server_id,user_id) VALUES(?, ?, ?)',
        [body, serverid, userid]);
    var jsonbody = {
      "body": body,
      "datetime": "",
      "server_id": "",
      "table_name": "scriptures",
      "user_id": userid,
    };
    Map<String, String> header = {"Content-type": "application/json"};
    var url =
        'https://growth.christianappdevelopers.com/index.php/MobileApi/synctable';
    var response =
        await http.post(url, body: jsonEncode(jsonbody), headers: header);
    var datas = response.body;
    print(response.body);
    if (response.statusCode == 200) {
      var serverobj = jsonDecode(response.body);
      await db.rawUpdate('UPDATE scriptures SET server_id = ? WHERE id = ?',
          [serverobj['last_id'], id2]);
    }
  }

  Future<List> getData(String char) async {
    print("get data $char");
    List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM personal_note where char = ? order by id desc', [char]);
    if (maps.isEmpty) {
      return [];
    } else {
      return maps;
    }
  }

  Future<List> getDataBibleStudy(String char) async {
    List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM bible_study where char = ?  order by id', [char]);
    if (maps.isEmpty) {
      print("no data");
      return [];
    } else {
      return maps;
    }
  }

  Future<List> getDataBibleStudyCount() async {
    List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT count(id) as total, id FROM bible_study order by id desc');
    if (maps.isEmpty) {
      print("no data");
      return [];
    } else {
      return maps;
    }
  }

  Future<List> getDataPersonalNotesCount() async {
    List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT count(id) as total, id FROM personal_note order by id desc');
    if (maps.isEmpty) {
      print("no data");
      return [];
    } else {
      return maps;
    }
  }

  Future<List> getDataScriptsCount() async {
    List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT count(id) as total, id FROM scriptures order by id desc');
    if (maps.isEmpty) {
      print("no data");
      return [];
    } else {
      return maps;
    }
  }

  Future<List> getDataScript() async {
    List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM scriptures  order by id desc');
    if (maps.isEmpty) {
      return [];
    } else {
      return maps;
    }
  }

  Future<void> deleteDataBibleStudy() async {
    await db.rawQuery('delete  FROM bible_study');
  }

  Future<void> deleteData(id, serverid) async {
    await db.rawQuery('delete  FROM personal_note where id = ? ', [id]);
    var jsonbody = {
      "server_id": serverid,
      "table_name": "notes",
    };
    Map<String, String> header = {"Content-type": "application/json"};
    var url =
        'https://growth.christianappdevelopers.com/index.php/MobileApi/synctableDelete';
    var response =
        await http.post(url, body: jsonEncode(jsonbody), headers: header);
    print(response.body);
    if (response.statusCode == 200) {
      var serverobj = jsonDecode(response.body);
    }
  }

  Future<void> deleteDataScript(id, serverid) async {
    await db.rawQuery('delete  FROM scriptures where id = ? ', [id]);
    var jsonbody = {
      "server_id": serverid,
      "table_name": "scriptures",
    };
    Map<String, String> header = {"Content-type": "application/json"};
    var url =
        'https://growth.christianappdevelopers.com/index.php/MobileApi/synctableDelete';
    var response =
        await http.post(url, body: jsonEncode(jsonbody), headers: header);
    print(response.body);
    if (response.statusCode == 200) {
      var serverobj = jsonDecode(response.body);
    }
  }

  void updateData(id, datas, title, server_id) async {
    await db.rawUpdate(
        'UPDATE personal_note SET body = ?, title=? WHERE id = ?', [datas, title, id]);
    var jsonbody = {
      "body": datas,
      "title":title,
      "server_id": server_id,
      "table_name": "notes",
    };
    Map<String, String> header = {"Content-type": "application/json"};
    var url =
        'https://growth.christianappdevelopers.com/index.php/MobileApi/synctableUpdate';
    var response =
        await http.post(url, body: jsonEncode(jsonbody), headers: header);
    print(response.body);
    if (response.statusCode == 200) {
      var serverobj = jsonDecode(response.body);
    }
  }

  void updateDataScript(id, datas, server_id) async {
    await db
        .rawUpdate('UPDATE scriptures SET body = ? WHERE id = ?', [datas, id]);
    var jsonbody = {
      "body": datas,
      "server_id": server_id,
      "table_name": "scriptures",
    };
    Map<String, String> header = {"Content-type": "application/json"};
    var url =
        'https://growth.christianappdevelopers.com/index.php/MobileApi/synctableUpdate';
    var response =
        await http.post(url, body: jsonEncode(jsonbody), headers: header);
    print(response.body);
    if (response.statusCode == 200) {
      var serverobj = jsonDecode(response.body);
    }
  }

  void insertAuthUser({user_id, name, email}) async {
    print(user_id);
    await db.rawInsert(
        'INSERT INTO auth_user(name, email,user_id) VALUES(?, ?, ?)',
        [name, email, user_id]);
  }

  Future<Map> getAuthUser() async {
    List<Map<String, dynamic>> maps = await db
        .rawQuery('SELECT * FROM auth_user  order by id desc limit 0,1');
    if (maps.isEmpty) {
      return {"status": false};
    } else {
      return {"status": true, "userdata": maps[0]};
    }
  }

  Future<void> deleteUserData() async {
    await db.rawQuery('delete  FROM auth_user ');
    await db.rawQuery('delete  FROM scriptures ');
    await db.rawQuery('delete  FROM personal_note ');
    await db.rawQuery('delete  FROM bible_study');
  }
}
