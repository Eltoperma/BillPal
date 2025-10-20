import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import 'base_repository.dart';

/// Repository für Position-Operationen basierend auf dem ERD-Schema
class PositionRepository implements BaseRepository<Map<String, dynamic>> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<int> insert(Map<String, dynamic> position) async {
    final Database db = await _databaseHelper.database;
    return await db.insert('positions', position);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final Database db = await _databaseHelper.database;
    return await db.query('positions');
  }

  @override
  Future<Map<String, dynamic>?> getById(int id) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'positions',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  @override
  Future<int> update(Map<String, dynamic> position) async {
    final Database db = await _databaseHelper.database;
    return await db.update(
      'positions',
      position,
      where: 'id = ?',
      whereArgs: [position['id']],
    );
  }

  @override
  Future<int> delete(int id) async {
    final Database db = await _databaseHelper.database;
    return await db.delete(
      'positions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Position-spezifische Methoden basierend auf ERD
  Future<List<Map<String, dynamic>>> getPositionsByBillId(int billId) async {
    final Database db = await _databaseHelper.database;
    return await db.query(
      'positions',
      where: 'bill_id = ?',
      whereArgs: [billId],
    );
  }

  Future<List<Map<String, dynamic>>> getPositionsByUserId(int userId) async {
    final Database db = await _databaseHelper.database;
    return await db.query(
      'positions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getOpenPositions() async {
    final Database db = await _databaseHelper.database;
    return await db.query(
      'positions',
      where: 'open = ?',
      whereArgs: [1], // 1 = true für boolean
    );
  }

  Future<double> getTotalAmountByBillId(int billId) async {
    final Database db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM positions 
      WHERE bill_id = ?
    ''', [billId]);
    
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<double> getOpenAmountByUserId(int userId) async {
    final Database db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM positions 
      WHERE user_id = ? AND open = 1
    ''', [userId]);
    
    return (result.first['total'] as double?) ?? 0.0;
  }
}