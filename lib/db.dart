import 'dart:async';

import 'package:flutter_cal/calendar_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

abstract class DB {
  static Database _db;

  static int get _version => 1;

  static Future<void> init() async {
    try {
      String _path = await getDatabasesPath();
      String _dbpath = p.join(_path, 'cal1.db');

      _db = await openDatabase(_dbpath,
          version: _version, onCreate: onCreate);
      print(_version);
    } catch (ex) {
      print(ex);
    }
  }

  static FutureOr<void> onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE events (id INTEGER PRIMARY KEY NOT NULL, name STRING, date STRING, setCounter INTEGER)');
  }

  static Future<List<Map<String, dynamic>>> query(String table) async =>
    await _db.query(table);

  static Future<int> insert(String table, CalendarItem item) async =>
    await _db.insert(table, item.toMap());

  static Future<int> delete(String table, CalendarItem item) async =>
      await _db.delete(table, where: 'id = ?', whereArgs: [item.id]);
}