import 'package:coin_log/models/AccountLog.dart';
import 'package:coin_log/services/DatabaseService.dart';
import 'package:sqflite/sqflite.dart';

class AccountLogService {

  final String TABLE_NAME = "CL_ACCOUNT_LOG";

  Future<List<AccountLog>> listByAccountIdYearMonth(int accountId, String year, String month) async {
    final db = await DatabaseService().database;

    List<Map<String, dynamic>> maps = await db.query(
      TABLE_NAME,
      where: 'ACCOUNT_ID = ? AND STRFTIME("%Y", RECORD_DATE) = ? and CAST(STRFTIME("%m", RECORD_DATE) AS INTEGER) = ?',
      whereArgs: [accountId, year, month],
      orderBy: 'RECORD_DATE DESC, CREATED_ON DESC, IDENTIFIER DESC'
    );

    return maps.map((e) => AccountLog.fromMap(e)).toList();
  }
}