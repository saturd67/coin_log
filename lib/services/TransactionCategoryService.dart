import 'package:coin_log/models/TransactionCategory.dart';
import 'package:coin_log/services/DatabaseService.dart';

class TransactionCategoryService {

  final String TABLE_NAME = "CL_TRANSACTION_CATEGORY";
  
  Future<int?> save(TransactionCategory transactionCategory) async {
    final db = await DatabaseService().database;
    TransactionCategory? lastTransactionCategory = await findLastByType(transactionCategory.type);
    transactionCategory.sequence = lastTransactionCategory != null ? lastTransactionCategory.sequence + 1 : 1;
    return await db.insert(TABLE_NAME, transactionCategory.toMap());
  }

  Future<int?> update(TransactionCategory transactionCategory) async {
    final db = await DatabaseService().database;
    return await db.update(
      TABLE_NAME, 
      transactionCategory.toMap(),
      where: 'identifier = ?',
      whereArgs: [transactionCategory.identifier]);
  }

  Future<void> updateSequence(List<TransactionCategory> transactionCategories) async {
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

  Future<List<TransactionCategory>> list() async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(TABLE_NAME);
    return maps.map((e) => TransactionCategory.fromMap(e)).toList();
  }

  Future<List<TransactionCategory>> listByType(String type) async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
        TABLE_NAME,
        where: "type = ?",
        orderBy: "sequence",
        whereArgs: [type]
    );
    return maps.map((e) => TransactionCategory.fromMap(e)).toList();
  }

  Future<TransactionCategory?> findById(int identifier) async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
        TABLE_NAME,
        where: 'identifier = ?',
        limit: 1,
        whereArgs: [identifier]
    );

    TransactionCategory? transactionCategory;
    if (maps.isNotEmpty) {
      transactionCategory = TransactionCategory.fromMap(maps.first);
    }

    return transactionCategory;
  }

  Future<TransactionCategory?> findLastByType(String type) async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
      TABLE_NAME, 
      where: 'type = ?',
      orderBy: 'sequence desc',
      limit: 1,
      whereArgs: [type]
    );

    TransactionCategory? transactionCategory;
    if (maps.isNotEmpty) {
      transactionCategory = TransactionCategory.fromMap(maps.first);
    }

    return transactionCategory;
  }
}