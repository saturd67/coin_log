import 'dart:io';

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  final _log = Logger('DatabaseService');

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _initDB(false);
    return _db!;
  }

  Future<void> createTransactionCategoryTable(Database db) async {
    await db.execute('''
          CREATE TABLE CL_TRANSACTION_CATEGORY (
            IDENTIFIER INTEGER PRIMARY KEY AUTOINCREMENT,
            NAME VARCHAR(10) NOT NULL,
            ICON VARCHAR(50) NOT NULL,
            TYPE VARCHAR(25) NOT NULL,
            SEQUENCE INTEGER NOT NULL
          );
        ''');
  }

  Future<void> createAccountTable(Database db) async {
    await db.execute('''
          CREATE TABLE CL_ACCOUNT (
            IDENTIFIER INTEGER PRIMARY KEY AUTOINCREMENT,
            NAME VARCHAR(10) NOT NULL,
            ICON VARCHAR(50) NOT NULL,
            SEQUENCE INTEGER NOT NULL,
            BALANCE DOUBLE NOT NULL,
            IS_DEFAULT INTEGER NOT NULL
          );
    ''');
  }

  Future<Database> _initDB(bool isResetDatabase) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'coin_log.db');

    if (isResetDatabase) {
      final dbFile = File(path);
      if (await dbFile.exists()) {
        await dbFile.delete();
        _log.info('Database file deleted: $path');
      }

      else {
        _log.info('No database file found at $path');
      }
    }

    return await openDatabase(
      path,
      version: 2,
      onCreate: (Database database, int version) async {
        await createTransactionCategoryTable(database);
        await createAccountTable(database);
      },
      onUpgrade: (Database database, int oldVersion, int newVersion) async {
        // if (oldVersion < 2) {
        //   await database.execute("ALTER TABLE ...");
        // }
      }
    );
  }

  Future<void> checkDatabaseFileExists(String dbName) async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, dbName);

    final dbFile = File(path);
    final exists = await dbFile.exists();

    if (exists) {
      _log.info('Database file exists at: $path');
    }

    else {
      _log.info('Database file does Not exist at : $path');
    }
  }

  Future<void> listTables(Database db) async {
    final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';"
    );

    _log.info('Tables in database:');
    for (final table in tables) {
      _log.info(table['name']);
    }
  }
}