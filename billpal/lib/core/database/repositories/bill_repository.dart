import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../logging/app_logger.dart';
import 'base_repository.dart';

/// Repository für Bill-Operationen basierend auf dem ERD-Schema
class BillRepository implements BaseRepository<Map<String, dynamic>> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<int> insert(Map<String, dynamic> bill) async {
    try {
      AppLogger.sql.debug('🔸 BillRepository.insert aufgerufen mit: $bill');
      final db = await DatabaseHelper().database;
      AppLogger.sql.debug('🔸 Database-Objekt erhalten: $db');
      final result = await db.insert('bills', bill);
      AppLogger.sql.success('🔸 Insert erfolgreich: $result');
      return result;
    } catch (e, stackTrace) {
      AppLogger.sql.error('❌ BillRepository.insert FEHLER: $e');
      AppLogger.sql.error('📍 Repository StackTrace: $stackTrace');
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

  /// Aktualisiert den Status einer Bill
  Future<int> updateBillStatus(int billId, String status) async {
    final Database db = await _databaseHelper.database;
    return await db.update(
      'bills',
      {'status': status},
      where: 'id = ?',
      whereArgs: [billId],
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