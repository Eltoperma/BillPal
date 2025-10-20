import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import 'base_repository.dart';

/// Repository für User-Operationen basierend auf dem ERD-Schema
class UserRepository implements BaseRepository<Map<String, dynamic>> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<int> insert(Map<String, dynamic> user) async {
    final Database db = await _databaseHelper.database;
    return await db.insert('users', user);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final Database db = await _databaseHelper.database;
    return await db.query('users');
  }

  @override
  Future<Map<String, dynamic>?> getById(int id) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  @override
  Future<int> update(Map<String, dynamic> user) async {
    final Database db = await _databaseHelper.database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  @override
  Future<int> delete(int id) async {
    final Database db = await _databaseHelper.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // User-spezifische Methoden
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<List<Map<String, dynamic>>> getUsersByRole(int roleId) async {
    final Database db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT u.* FROM users u
      INNER JOIN user_roles ur ON u.id = ur.user_id
      WHERE ur.role_id = ?
    ''', [roleId]);
  }
}