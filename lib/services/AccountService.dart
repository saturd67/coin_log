import 'package:coin_log/objects/Account.dart';
import 'package:coin_log/services/DatabaseService.dart';
import 'package:sqflite/sqflite.dart';

class AccountService {

  final String TABLE_NAME = "CL_ACCOUNT";

  Future<int?> save(Account account) async {
    final db = await DatabaseService().database;

    Account? lastAccount = await findLast();
    account.sequence = lastAccount != null ? lastAccount.sequence + 1 : 1;

    await db.transaction((transaction) async {
      if (account.isDefault) {
        await _resetIsDefault(transaction);
      }
      return await transaction.insert(TABLE_NAME, account.toMap());
    });
    return null;
  }

  Future<int?> update(Account account) async {
    final db = await DatabaseService().database;

    await db.transaction((transaction) async {
      if (account.isDefault) {
        await _resetIsDefault(transaction);
      }
      return await transaction.update(
        TABLE_NAME,
        account.toMap(),
        where: 'identifier = ?',
        whereArgs: [account.identifier]
      );
    });

    return null;
  }

  Future<void> updateSequence(List<Account> transactionCategories) async {
    final db = await DatabaseService().database;
    await db.transaction((transaction) async {
      for (int i = 0; i < transactionCategories.length; i++) {
        transactionCategories[i].sequence = i + 1;
        await transaction.update(
            TABLE_NAME,
            transactionCategories[i].toMap(),
            where: 'identifier = ?',
            whereArgs: [transactionCategories[i].identifier]);
      }
    });
  }

  Future<int?> delete(int identifier) async {
    final db = await DatabaseService().database;
    return await db.delete(
        TABLE_NAME,
        where: 'identifier = ?',
        whereArgs: [identifier]
    );
  }

  Future<List<Account>> list() async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
        TABLE_NAME,
        orderBy: 'sequence'
    );
    return maps.map((e) => Account.fromMap(e)).toList();
  }

  Future<Account?> findById(int identifier) async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
        TABLE_NAME,
        where: 'identifier = ?',
        limit: 1,
        whereArgs: [identifier]
    );

    Account? account;
    if (maps.isNotEmpty) {
      account = Account.fromMap(maps.first);
    }

    return account;
  }

  Future<Account?> findLast() async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
        TABLE_NAME,
        limit: 1,
        orderBy: 'sequence desc'
    );

    Account? account;
    if (maps.isNotEmpty) {
      account = Account.fromMap(maps.first);
    }

    return account;
  }

  Future<void> _resetIsDefault(Transaction transaction) async {
    await transaction.rawUpdate("UPDATE $TABLE_NAME SET IS_DEFAULT = 0 WHERE IS_DEFAULT = 1", []);
  }
}