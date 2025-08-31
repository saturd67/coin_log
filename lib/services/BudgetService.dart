import '../models/Budget.dart';
import 'DatabaseService.dart';

class BudgetService {
  final String TABLE_NAME = "CL_BUDGET";

  Future<int?> save(Budget budget) async {
    final db = await DatabaseService().database;
    return await db.insert(TABLE_NAME, budget.toMap());
  }

  Future<int?> update(Budget budget) async {
    final db = await DatabaseService().database;
    return await db.update(
        TABLE_NAME,
        budget.toMap(),
        where: 'identifier = ?',
        whereArgs: [budget.identifier]);
  }

  Future<int?> delete(int identifier) async {
    final db = await DatabaseService().database;
    return await db.delete(
        TABLE_NAME,
        where: 'identifier = ?',
        whereArgs: [identifier]
    );
  }

  Future<Budget?> findById(int identifier) async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(
        TABLE_NAME,
        where: 'identifier = ?',
        limit: 1,
        whereArgs: [identifier]
    );

    Budget? budget;
    if (maps.isNotEmpty) {
      budget = Budget.fromMap(maps.first);
    }

    return budget;
  }
  
  Future<List<Budget>> list() async {
    final db = await DatabaseService().database;
    List<Map<String, dynamic>> maps = await db.query(TABLE_NAME);
    return maps.map((e) => Budget.fromMap(e)).toList();
  }

}