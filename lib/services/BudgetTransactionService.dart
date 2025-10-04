import 'package:coin_log/models/BudgetTransaction.dart';

import '../models/Budget.dart';
import 'DatabaseService.dart';

class BudgetTransactionService {
  final String TABLE_NAME = "CL_BUDGET_TRANSACTION";

  Future<int?> save(BudgetTransaction budgetTransaction) async {
    final db = await DatabaseService().database;
    return await db.insert(TABLE_NAME, budgetTransaction.toMap());
  }

  Future<int?> update(BudgetTransaction budgetTransaction) async {
    final db = await DatabaseService().database;

    return await db.update(
        TABLE_NAME,
        budgetTransaction.toMap(),
        where: 'identifier = ?',
        whereArgs: [budgetTransaction.identifier]);
  }

  Future<void> updateByYearMonth(int year, int? month, List<BudgetTransaction> budgetTransactions) async {
    final db = await DatabaseService().database;

    Period period = month != null ? Period.monthly : Period.yearly;

    List<String> wheres = [];
    List<Object> whereArgs = [];

    wheres.add('PERIOD = ?');
    whereArgs.add(period.name);

    wheres.add("AND strftime('%Y', BT.DATE) AS YEAR = ?");
    whereArgs.add(year);

    if (month != null) {
      wheres.add("AND strftime('%m', BT.DATE) AS MONTH = ?");
      whereArgs.add(month);
    }

    await db.transaction((transaction) async {
      await transaction.delete(
        TABLE_NAME,
        where: wheres.join(" "),
        whereArgs: whereArgs
      );

      for (final budgetTransaction in budgetTransactions) {
        transaction.insert(TABLE_NAME, budgetTransaction.toMap());
      }
    });
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

  Future<BudgetTransaction?> findById(int identifier) async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
        TABLE_NAME,
        where: 'identifier = ?',
        limit: 1,
        whereArgs: [identifier]
    );

    BudgetTransaction? budgetTransaction;
    if (maps.isNotEmpty) {
      budgetTransaction = BudgetTransaction.fromMap(maps.first);
    }

    return budgetTransaction;
  }

  Future<List<BudgetTransaction>> list() async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
        TABLE_NAME
    );
    return maps.map((e) => BudgetTransaction.fromMap(e)).toList();
  }

  Future<List<BudgetTransaction>> listByYearMonth(int year, int? month) async {
    final db = await DatabaseService().database;

    List<Object> whereArgs = [];

    String query = '''
      SELECT 
        BT.IDENTIFIER              AS BT_IDENTIFIER,
        BT.TRANSACTION_CATEGORY_ID AS BT_TRANSACTION_CATEGORY_ID,
        BT.BUDGET_ID               AS BT_BUDGET_ID,
        BT.DATE                    AS BT_DATE,
        BT.AMOUNT                  AS BT_AMOUNT,
      
        B.IDENTIFIER               AS B_IDENTIFIER,
        B.TRANSACTION_CATEGORY_ID  AS B_TRANSACTION_CATEGORY_ID,
        B.PERIOD                   AS B_PERIOD,
        B.AMOUNT                   AS B_AMOUNT
      FROM CL_BUDGET_TRANSACTION BT 
      JOIN CL_BUDGET B 
        ON BT.BUDGET_ID = B.IDENTIFIER 
      WHERE 1=1 
        AND B.PERIOD = ?
        AND strftime('%Y', BT.DATE) = ? 
    ''';

    whereArgs.add(month != null ? Period.monthly.name : Period.yearly.name);
    whereArgs.add(year.toString());

    if (month != null) {
      query += '''
        AND strftime('%m', BT.DATE) = ?
      ''';

      whereArgs.add(month.toString());
    }
    
    List<Map<String, dynamic>> maps = await db.rawQuery(
        query,
        whereArgs
    );

    List<BudgetTransaction> budgetTransactions = [];
    if (maps.isNotEmpty) {
      for (final map in maps) {
        final budgetTransaction = BudgetTransaction.fromMap({
          'IDENTIFIER': map['BT_IDENTIFIER'],
          'TRANSACTION_CATEGORY_ID': map['BT_TRANSACTION_CATEGORY_ID'],
          'BUDGET_ID': map['BT_BUDGET_ID'],
          'DATE': map['BT_DATE'],
          'AMOUNT': map['BT_AMOUNT']
        });

        final budget = Budget.fromMap({
          'IDENTIFIER': map['B_IDENTIFIER'],
          'TRANSACTION_CATEGORY_ID': map['B_TRANSACTION_CATEGORY_ID'],
          'PERIOD': map['B_PERIOD'],
          'AMOUNT': map['B_AMOUNT'],
          'IS_CLOSED': map['B_IS_CLOSED'],
        });

        budgetTransaction.budget = budget;
        budgetTransactions.add(budgetTransaction);
      }
    }

    return budgetTransactions;
  }
}