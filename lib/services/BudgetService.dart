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
    return await db.update(
        TABLE_NAME,
        {'IS_CLOSED': true},
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
  
  Future<List<Budget>> listByIsClosed(bool? isClosed) async {
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
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null
    );

    return maps.map((e) => Budget.fromMap(e)).toList();
  }

  Future<List<Budget>> listByPeriodIsClosed(Period? period, bool? isClosed) async {
    final db = await DatabaseService().database;

    List<String> wheres = [];
    List<Object> whereArgs = [];
    
    wheres.add('1=1');
    
    if (period != null) {
      wheres.add('AND PERIOD = ?');
      whereArgs.add(period.name);
    }

    if (isClosed != null) {
      wheres.add('AND IS_CLOSED = ?');
      whereArgs.add(isClosed);
    }

    List<Map<String, dynamic>> maps = await db.query(
      TABLE_NAME,
      where: wheres.isNotEmpty ? wheres.join(" ") : null,
      whereArgs: whereArgs
    );

    return maps.map((map) => Budget.fromMap(map)).toList();
  }

}