import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB(true);
    return _db!;
  }

  Future<Database> _initDB(bool isResetDatabase) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'coin_log.db');

    if (isResetDatabase) {
      final dbFile = File(path);
      if (await dbFile.exists()) {
        await dbFile.delete();
        print('[DatabaseService] - Database file deleted: $path');
      }

      else {
        print('[DatabaseService] - No database file found at $path');
      }
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE CL_TRANSACTION_CATEGORY (
            IDENTIFIER INTEGER PRIMARY KEY AUTOINCREMENT,
            NAME VARCHAR(100) NOT NULL,
            ICON VARCHAR(50) NOT NULL,
            TYPE VARCHAR(25) NOT NULL,
            SEQUENCE INTEGER NOT NULL
          );
        ''');
      },
    );
  }

  Future<void> checkDatabaseFileExists(String dbName) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    final dbFile = File(path);
    final exists = await dbFile.exists();

    if (exists) {
      print('[DatabaseService] - Database file exists at: $path');
    }

    else {
      print('[DatabaseService] - Database file does Not exist at : $path');
    }
  }

  Future<void> listTables(Database db) async {
    final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';"
    );

    print("[DatabaseService] - Tables in database:");
    for (final table in tables) {
      print(table['name']);
    }
  }
}