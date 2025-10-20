import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import 'base_repository.dart';

/// Repository für Bill-Operationen basierend auf dem ERD-Schema
class BillRepository implements BaseRepository<Map<String, dynamic>> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<int> insert(Map<String, dynamic> bill) async {
    try {
      print('🔸 BillRepository.insert aufgerufen mit: $bill');
      final Database db = await _databaseHelper.database;
      print('🔸 Database-Objekt erhalten: $db');
      final result = await db.insert('bills', bill);
      print('🔸 Insert erfolgreich: $result');
      return result;
    } catch (e, stackTrace) {
      print('❌ BillRepository.insert FEHLER: $e');
      print('📍 Repository StackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final Database db = await _databaseHelper.database;
    return await db.query('bills');
  }

  @override
  Future<Map<String, dynamic>?> getById(int id) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  @override
  Future<int> update(Map<String, dynamic> bill) async {
    final Database db = await _databaseHelper.database;
    return await db.update(
      'bills',
      bill,
      where: 'id = ?',
      whereArgs: [bill['id']],
    );
  }

  @override
  Future<int> delete(int id) async {
    final Database db = await _databaseHelper.database;
    return await db.delete(
      'bills',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Bill-spezifische Methoden basierend auf ERD
  Future<List<Map<String, dynamic>>> getBillsByUserId(int userId) async {
    final Database db = await _databaseHelper.database;
    return await db.query(
      'bills',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>?> getBillWithPositions(int billId) async {
    final Database db = await _databaseHelper.database;
    
    final billResult = await db.query(
      'bills',
      where: 'id = ?',
      whereArgs: [billId],
    );
    
    if (billResult.isEmpty) return null;
    
    final positionsResult = await db.query(
      'positions',
      where: 'bill_id = ?',
      whereArgs: [billId],
    );
    
    final bill = Map<String, dynamic>.from(billResult.first);
    bill['positions'] = positionsResult;
    return bill;
  }
}