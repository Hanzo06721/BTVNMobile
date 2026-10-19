import '../models/expense.dart';
import '../utils/database_helper.dart';

class ExpenseController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertExpense(Expense e) async {
    final db = await _dbHelper.database;
    final map = e.toMap()..remove('id'); // để AUTOINCREMENT tự sinh id
    await db.insert('expenses', map);
  }

  Future<void> updateExpense(Expense e) async {
    final db = await _dbHelper.database;
    await db.update('expenses', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<void> deleteExpense(int id) async {
    final db = await _dbHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> fetchExpenses() async {
    final db = await _dbHelper.database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    return maps.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> searchExpenses(String query) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'expenses',
      where: 'content LIKE ? OR note LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map(Expense.fromMap).toList();
  }

  Future<double> totalAmount() async {
    final db = await _dbHelper.database;
    final r = await db.rawQuery('SELECT SUM(amount) AS total FROM expenses');
    return (r.first['total'] as num?)?.toDouble() ?? 0;
  }
}
