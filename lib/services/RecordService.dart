import 'package:coin_log/objects/Account.dart';
import 'package:coin_log/objects/Record.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/DatabaseService.dart';
import 'package:coin_log/utils/BalanceManager.dart';

class RecordService {

  final String TABLE_NAME = "CL_RECORD";

  final AccountService accountService = AccountService();

  Future<int?> saveTransaction(Record record) async {
    final db = await DatabaseService().database;

    await BalanceManager.updateBalanceOnSaveTransactionRecord(record);

    return await db.insert(TABLE_NAME, record.toMap());
  }

  Future<int?> updateTransaction(Record record) async {
    final db = await DatabaseService().database;

    await BalanceManager.updateBalanceOnUpdateTransactionRecord(record);

    return await db.update(
      TABLE_NAME,
      record.toMap(),
      where: 'identifier = ?',
      whereArgs: [record.identifier]);
  }

  Future<int?> deleteTransaction(Record record) async {
    final db = await DatabaseService().database;

    await BalanceManager.updateBalanceOnDeleteTransactionRecord(record);

    return await db.delete(
        TABLE_NAME,
        where: 'identifier = ?',
        whereArgs: [record.identifier]
    );
  }

  Future<int?> saveTransfer(Record record) async {
    final db = await DatabaseService().database;

    await BalanceManager.updateBalanceOnSaveTransferRecord(record);

    return await db.insert(TABLE_NAME, record.toMap());
  }

  Future<int?> updateTransfer(Record record) async {
    final db = await DatabaseService().database;

    await BalanceManager.updateBalanceOnUpdateTransferRecord(record);

    return await db.update(
        TABLE_NAME,
        record.toMap(),
        where: 'identifier = ?',
        whereArgs: [record.identifier]);
  }

  Future<int?> deleteTransfer(Record record) async {
    final db = await DatabaseService().database;

    await BalanceManager.updateBalanceOnDeleteTransferRecord(record);

    return await db.delete(
        TABLE_NAME,
        where: 'identifier = ?',
        whereArgs: [record.identifier]
    );
  }

  Future<Record?> findById(int identifier) async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
      TABLE_NAME,
      where: 'identifier = ?',
      limit: 1,
      whereArgs: [identifier]
    );

    Record? record;
    if (maps.isNotEmpty) {
      record = Record.fromMap(maps.first);
    }

    return record;
  }

  Future<List<Record>> list() async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
      TABLE_NAME,
      orderBy: 'date desc'
    );
    return maps.map((e) => Record.fromMap(e)).toList();
  }

  Future<List<Record>> listByYearMonth(String year, String month) async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
      TABLE_NAME,
      where: 'STRFTIME("%Y", date) = ? and CAST(STRFTIME("%m", date) AS INTEGER) = ?',
      orderBy: 'date desc',
      whereArgs: [year, month]
    );
    return maps.map((e) => Record.fromMap(e)).toList();
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

  Future<List<Map<String, dynamic>>> listTransactionCategoryAmountByTypeYearMonth(String? type, String? year, String? month) async {
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

  Future<List<Map<String, dynamic>>> listDailyTransactionCategoryAmountByYearMonthTransactionType(String transactionType, String year, String month) async {

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

  Future<List<Map<String, dynamic>>> listMonthlyTransactionCategoryAmountByYearMonthTransactionType(String transactionType, String year) async {

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
}