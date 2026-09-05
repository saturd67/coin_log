import 'package:coin_log/models/Record.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/DatabaseService.dart';
import 'package:coin_log/utils/BalanceManager.dart';
import 'package:sqflite/sqflite.dart';

import '../models/TransactionCategory.dart';

class RecordService {

  final String TABLE_NAME = "CL_RECORD";

  final AccountService accountService = AccountService();

  Future<int?> saveTransaction(Record_ record) async {
    final db = await DatabaseService().database;
    final int? oriIdentifier = record.identifier;

    try {
      await db.transaction((transaction) async {
        record.identifier = await transaction.insert(TABLE_NAME, record.toMap());

        await BalanceManager.updateBalanceOnSaveTransactionRecord(transaction, record);
      });
    }
    catch (e) {
      record.identifier = oriIdentifier;
      rethrow;
    }

    return record.identifier;
  }

  Future<int?> updateTransaction(Record_ record) async {
    final db = await DatabaseService().database;

    return await db.transaction((transaction) async {
      await BalanceManager.updateBalanceOnUpdateTransactionRecord(transaction, record);

      return await transaction.update(
          TABLE_NAME,
          record.toMap(),
          where: 'identifier = ?',
          whereArgs: [record.identifier]);
    });
  }

  Future<int?> deleteTransaction(Record_ record) async {
    final db = await DatabaseService().database;

    return await db.transaction((transaction) async {
      int effectedRowCount = await transaction.delete(
          TABLE_NAME,
          where: 'identifier = ?',
          whereArgs: [record.identifier]
      );

      await BalanceManager.updateBalanceOnDeleteTransactionRecord(transaction, record);

      return effectedRowCount;
    });
  }

  Future<int?> saveTransfer(Record_ record) async {
    final db = await DatabaseService().database;
    final int? oriIdentifier = record.identifier;

    try {
      await db.transaction((transaction) async {
        record.identifier = await transaction.insert(TABLE_NAME, record.toMap());

        await BalanceManager.updateBalanceOnSaveTransferRecord(transaction, record);
      });
    }
    catch (e) {
      record.identifier = oriIdentifier;
      rethrow;
    }

    return record.identifier;
  }

  Future<int?> updateTransfer(Record_ record) async {
    final db = await DatabaseService().database;

    return await db.transaction((transaction) async {
      await BalanceManager.updateBalanceOnUpdateTransferRecord(transaction, record);

      return await transaction.update(
          TABLE_NAME,
          record.toMap(),
          where: 'identifier = ?',
          whereArgs: [record.identifier]);
    });
  }

  Future<int?> deleteTransfer(Record_ record) async {
    final db = await DatabaseService().database;

    return await db.transaction((transaction) async {
      await BalanceManager.updateBalanceOnDeleteTransferRecord(transaction, record);

      return await transaction.delete(
          TABLE_NAME,
          where: 'identifier = ?',
          whereArgs: [record.identifier]
      );
    });
  }

  Future<Record_?> findById(int identifier) async {
    final db = await DatabaseService().database;
    return await findByIdWithExecutor(db, identifier);
  }

  Future<Record_?> findByIdWithExecutor(DatabaseExecutor executor, int identifier) async {
    List<Map<String, dynamic>> maps = await executor.query(
      TABLE_NAME,
      where: 'identifier = ?',
      limit: 1,
      whereArgs: [identifier]
    );

    Record_? record;
    if (maps.isNotEmpty) {
      record = Record_.fromMap(maps.first);
    }

    return record;
  }

  Future<List<Record_>> list() async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
      TABLE_NAME,
      orderBy: 'date desc'
    );
    return maps.map((e) => Record_.fromMap(e)).toList();
  }

  Future<List<Record_>> listByYearMonthDay(String year, String month, String? day) async {
    final db = await DatabaseService().database;

    List<String> wheres = [
      'STRFTIME("%Y", date) = ? AND CAST(STRFTIME("%m", date) AS INTEGER) = ?'
    ];
    List<Object?> whereArgs = [year, month];

    if (day != null) {
      wheres.add('AND CAST(STRFTIME("%d", date) AS INTEGER) = ?');
      whereArgs.add(day);
    }

    List<Map<String, dynamic>> maps = await db.query(
      TABLE_NAME,
      where: wheres.join(" "),
      orderBy: 'date desc',
      whereArgs: whereArgs
    );
    return maps.map((e) => Record_.fromMap(e)).toList();
  }

  Future<double> sumByTypeYearMonth(String? type, String? year, String? month) async {

    String query = 'SELECT SUM(amount) as TOTAL FROM $TABLE_NAME WHERE 1=1 ';

    query += type != null ? 'AND type = ? ' : '';
    query += year != null ? 'AND STRFTIME("%Y", date) = ? ' : '';
    query += month != null ? 'AND CAST(STRFTIME("%m", date) AS INTEGER) = ? ' : '';

    List<Object?> arguments = [];
    if (type != null) {
      arguments.add(type);
    }

    if (year != null) {
      arguments.add(year);
    }

    if (month != null) {
      arguments.add(month);
    }

    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.rawQuery(query, arguments);

    return maps[0]["TOTAL"] ?? 0;
  }

  Future<List<Map<String, dynamic>>> listTransactionCategoryTotalByTypeYearMonth(String? type, String? year, String? month) async {
    String query = 'SELECT tc.name, SUM(x.amount) as TOTAL FROM $TABLE_NAME x '
        'JOIN CL_TRANSACTION_CATEGORY tc ON x.transaction_category_id = tc.identifier '
        'WHERE 1=1 ';
    query += type != null ? 'AND x.type = ? ' : '';
    query += year != null ? 'AND STRFTIME("%Y", x.date) = ? ' : '';
    query += month != null ? 'AND CAST(STRFTIME("%m", date) AS INTEGER) = ? ' : '';
    query += 'GROUP BY(tc.name)'
        'ORDER BY SUM(x.amount) DESC';

    List<Object?> arguments = [];
    if (type != null) {
      arguments.add(type);
    }

    if (year != null) {
      arguments.add(year);
    }

    if (month != null) {
      arguments.add(month);
    }

    final db = await DatabaseService().database;

    return await db.rawQuery(query, arguments);
  }

  Future<List<Map<String, dynamic>>> listDailyTransactionCategoryTotalByYearMonthTransactionType(String transactionType, String year, String month) async {

    String query = 'SELECT CAST(STRFTIME("%d", date) as INTEGER) as x_date, SUM(amount) as total FROM $TABLE_NAME '
        'WHERE 1=1 '
        'AND type = ? '
        'AND STRFTIME("%Y", date) = ? '
        'AND CAST(STRFTIME("%m", date) AS INTEGER) = ? '
        'GROUP BY CAST(STRFTIME("%d", date) AS INTEGER) '
        'ORDER BY CAST(STRFTIME("%d", date) AS INTEGER) ';

    List<Object?> arguments = [transactionType, year, month];

    final db = await DatabaseService().database;

    List<Map<String, dynamic>> maps = await db.rawQuery(query, arguments);
    List<Map<String, dynamic>> results = [];

    int lastDay = DateTime(int.parse(year), int.parse(month)).subtract(Duration(days: 1)).day;
    for (int day=1; day <= lastDay; day++) {
      Map<String, dynamic> map = maps.firstWhere((map) => map["x_date"] == day, orElse: () => {});
      if (map.isNotEmpty) {
        results.add({"x_date": day, "total": map["total"]});
      }

      else {
        results.add({"x_date": day, "total": 0});
      }
    }

    return results;
  }

  Future<List<Map<String, dynamic>>> listMonthlyTransactionCategoryTotalByYearMonthTransactionType(String transactionType, String year) async {

    String query = 'SELECT CAST(STRFTIME("%m", date) AS INTEGER) as x_date, SUM(amount) as total FROM $TABLE_NAME '
        'WHERE 1=1 '
        'AND type = ? '
        'AND STRFTIME("%Y", date) = ? '
        'GROUP BY CAST(STRFTIME("%m", date) AS INTEGER) '
        'ORDER BY CAST(STRFTIME("%m", date) AS INTEGER) ';

    List<Object?> arguments = [transactionType, year];

    final db = await DatabaseService().database;

    List<Map<String, dynamic>> maps = await db.rawQuery(query, arguments);
    List<Map<String, dynamic>> results = [];

    for (int month=1; month <= 12; month++) {
      Map<String, dynamic> map = maps.firstWhere((map) => map["x_date"] == month, orElse: () => {});
      if (map.isNotEmpty) {
        results.add({"x_date": month, "total": map["total"]});
      }

      else {
        results.add({"x_date": month, "total": 0});
      }
    }

    return results;
  }

  Future<Map<String, dynamic>> findRecordTotalByYearMonth(String transactionCategoryName, int year, int? month) async {
    final db = await DatabaseService().database;

    String query =  '''
      SELECT 
        R.IDENTIFIER AS R_IDENTIFIER,
        R.TRANSACTION_CATEGORY_ID AS R_TRANSACTION_CATEGORY_ID,
        SUM(R.AMOUNT) AS R_TOTAL,
        
        TC.IDENTIFIER AS TC_IDENTIFIER
      FROM CL_RECORD R
      JOIN CL_TRANSACTION_CATEGORY TC ON R.TRANSACTION_CATEGORY_ID = TC.IDENTIFIER 
      WHERE 1=1
        AND R.TYPE = 'Expense' 
        AND TC.NAME = ? 
        AND CAST(STRFTIME('%Y', R.DATE) AS INTEGER) = ?
    ''';
    query += month != null ? 'AND CAST(STRFTIME("%m", R.DATE) AS INTEGER) = ? ' : '';

    List<Object> whereArgs = [];

    whereArgs.add(transactionCategoryName);
    whereArgs.add(year);

    if (month != null) {
      whereArgs.add(month);
    }

    List<Map<String, dynamic>> maps = await db.rawQuery(
      query,
      whereArgs
    );

    return maps.first;
  }
}