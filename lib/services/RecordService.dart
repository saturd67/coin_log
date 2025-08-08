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
      where: 'strftime("%Y", date) = ? and strftime("%m", date) = ?',
      orderBy: 'date desc',
      whereArgs: [year, month]
    );
    return maps.map((e) => Record.fromMap(e)).toList();
  }

  Future<double> sumByTypeYearMonth(String type, String year, String month) async {
    print(year);
    print(month);
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT SUM(amount) as total FROM $TABLE_NAME '
          + 'WHERE type = ? '
          + 'AND strftime("%Y", date) = ? '
          + 'AND strftime("%m", date) = ?',
      [type, year, month]
    );
    return maps[0]["total"] ?? 0;
  }
}