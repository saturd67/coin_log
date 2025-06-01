import 'package:coin_log/objects/Account.dart';
import 'package:coin_log/objects/Record.dart';
import 'package:coin_log/services/AccountService.dart';
import 'package:coin_log/services/DatabaseService.dart';
import 'package:coin_log/utils/BalanceManager.dart';

class RecordService {

  final String TABLE_NAME = "CL_RECORD";

  final AccountService accountService = AccountService();

  Future<int?> save(Record record) async {
    final db = await DatabaseService().database;

    await BalanceManager.updateBalanceOnSaveRecord(record);

    return await db.insert(TABLE_NAME, record.toMap());
  }

  Future<int?> update(Record record) async {
    final db = await DatabaseService().database;

    await BalanceManager.updateBalanceOnUpdateRecord(record);

    return await db.update(
      TABLE_NAME,
      record.toMap(),
      where: 'identifier = ?',
      whereArgs: [record.identifier]);
  }

  Future<int?> delete(Record record) async {
    final db = await DatabaseService().database;

    await BalanceManager.updateBalanceOnDeleteRecord(record);

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
}