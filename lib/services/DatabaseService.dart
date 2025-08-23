import 'dart:io';

import 'package:logging/logging.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
    _db = await _initDB(true);
    return _db!;
  }

  Future<void> configDatabase(Database db) async {
    await db.execute('''
          PRAGMA foreign_keys = ON;
        ''');
  }

  Future<void> createTransactionCategoryTable(Database db) async {
    await db.execute('''
          CREATE TABLE CL_TRANSACTION_CATEGORY (
            IDENTIFIER INTEGER PRIMARY KEY AUTOINCREMENT,
            NAME VARCHAR(10) NOT NULL,
            ICON VARCHAR(50) NOT NULL,
            TYPE VARCHAR(25) NOT NULL,
            SEQUENCE INTEGER NOT NULL,
            IS_DELETED INTEGER NOT NULL
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
            IS_DEFAULT INTEGER NOT NULL,
            IS_DELETED INTEGER NOT NULL
          );
    ''');
  }

  Future<void> createAccountLogTable(Database db) async {
    await db.execute('''
      CREATE TABLE CL_ACCOUNT_LOG (
        IDENTIFIER        INTEGER PRIMARY KEY AUTOINCREMENT,
        ACCOUNT_ID        INTEGER NOT NULL,
        RECORD_ID         INTEGER NOT NULL,
        RECORD_ACTION     VARCHAR(8) CHECK(RECORD_ACTION IN ('insert', 'update', 'delete')) NOT NULL,
        OLD_BALANCE       DOUBLE NOT NULL,
        NEW_BALANCE       DOUBLE NOT NULL,
        CREATED_ON        DATETIME NOT NULL,
        
        FOREIGN KEY (ACCOUNT_ID) REFERENCES CL_ACCOUNT(IDENTIFIER)
      );
    ''');
  }

  Future<void> createRecordTable(Database db) async {
    await db.execute('''
          CREATE TABLE CL_RECORD (
            IDENTIFIER              INTEGER PRIMARY KEY AUTOINCREMENT,
            TRANSACTION_CATEGORY_ID INTEGER,
            SOURCE_ACCOUNT_ID       INTEGER,
            DESTINATION_ACCOUNT_ID  INTEGER,
            DATE                    DATE NOT NULL,
            DESCRIPTION             VARCHAR(50),
            TYPE                    VARCHAR(8) CHECK(TYPE IN ('Expense', 'Income', 'Transfer')) NOT NULL,
            AMOUNT                  DOUBLE NOT NULL,
            
            FOREIGN KEY (TRANSACTION_CATEGORY_ID) REFERENCES CL_TRANSACTION_CATEGORY(identifier),
            FOREIGN KEY (SOURCE_ACCOUNT_ID) REFERENCES CL_ACCOUNT(identifier),
            FOREIGN KEY (DESTINATION_ACCOUNT_ID) REFERENCES CL_ACCOUNT(identifier)
          );
        ''');
  }

  Future<void> insertTransactionCategory(Database db) async {
    await db.execute('''
      INSERT INTO CL_TRANSACTION_CATEGORY (NAME, ICON, TYPE, SEQUENCE, IS_DELETED) VALUES
        ("Breakfast", "coffee", "Expense", 1, False),
        ("Lunch", "lunch_dining", "Expense", 2, False),
        ("Dinner", "burger", "Expense", 3, False),
        ("Salary", "info", "Income", 1, False),
        ("Other", "star", "Income", 2, False);
    ''');
  }

  Future<void> insertAccount(Database db) async {
    await db.execute('''
      INSERT INTO CL_ACCOUNT (NAME, ICON, SEQUENCE, BALANCE, IS_DEFAULT, IS_DELETED) VALUES
        ("Bank", "account_balance", 1, 0.0, False, False),
        ("E-Wallet", "monetization_on", 2, 0.0, True, False),
        ("Cash", "money", 2, 0.0, False, False);
    ''');
  }
  
  // Future<void> insertRecords(Database db) async {
  //   await db.execute('''
  //     INSERT INTO CL_RECORD (TRANSACTION_CATEGORY_ID, SOURCE_ACCOUNT_ID, DATE, DESCRIPTION, TYPE, AMOUNT) VALUES
  //       (1, 2, "2025-06-01 10:07:36.085738", null, "Expense", 5.0),
  //       (2, 2, "2025-06-01 10:07:36.085738", null, "Expense", 15.0);
  //   ''');
  // }

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
      version: 1,
      onCreate: (Database database, int version) async {
        await configDatabase(database);
        await createTransactionCategoryTable(database);
        await createAccountTable(database);
        await createAccountLogTable(database);
        await createRecordTable(database);
        await insertTransactionCategory(database);
        await insertAccount(database);
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

  Future<void> backupDatabaseToDownloads() async {
    final dbPath = await getDatabasesPath();
    final originalDb = join(dbPath, "coin_log.db");
    final dbFile = File(originalDb);

    final directory = Directory('/storage/emulated/0/Download');
    final backupDb = join(directory.path, "coin_log_backup.db");

    if (await dbFile.exists()) {
      await dbFile.copy(backupDb);
      print("Exported DB to: $backupDb");
    }
    else {
      print("No database found at $originalDb");
    }
  }
}