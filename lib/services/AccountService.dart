import 'package:coin_log/models/Account.dart';
import 'package:coin_log/models/AccountLog.dart';
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

  Future<int?> logUpdateBalance(int accountId, int recordId, RecordAction recordAction, double oldBalance, double newBalance) async {
    final db = await DatabaseService().database;

    await db.transaction((transaction) async {
      await transaction.rawUpdate(
          "UPDATE $TABLE_NAME SET BALANCE = ? WHERE IDENTIFIER = ? ",
          [newBalance, accountId]
      );

      await transaction.rawInsert(
          """
        INSERT INTO CL_ACCOUNT_LOG (ACCOUNT_ID, RECORD_ID, RECORD_ACTION, OLD_BALANCE, NEW_BALANCE, CREATED_ON) VALUES 
        (?, ?, ?, ?, ?, CURRENT_TIMESTAMP);
        """,
          [accountId, recordId, recordAction.name, oldBalance, newBalance]
      );
    });
    return null;
  }

  Future<int?> delete(int identifier) async {
    final db = await DatabaseService().database;
    return await db.update(
        TABLE_NAME,
        {'IS_CLOSED': true},
        where: 'identifier = ?',
        whereArgs: [identifier]
    );
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

  Future<List<Account>> listByIsClosed(bool? isClosed) async {
    final db = await DatabaseService().database;

    List<String> wheres = [];
    List<Object> whereArgs = [];

    if (isClosed != null) {
      wheres.add('IS_CLOSED = ?');
      whereArgs.add(isClosed);
    }

    List<Map<String, dynamic>> maps = await db.query(
        TABLE_NAME,
        where: wheres.isNotEmpty ? wheres.join(" ") : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'sequence'
    );
    return maps.map((e) => Account.fromMap(e)).toList();
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
    await transaction.rawUpdate(
        "UPDATE $TABLE_NAME SET IS_DEFAULT = 0 WHERE IS_DEFAULT = 1",
        []
    );
  }
}