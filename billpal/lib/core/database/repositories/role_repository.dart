import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import 'base_repository.dart';

/// Repository für Role-Operationen basierend auf dem ERD-Schema
class RoleRepository implements BaseRepository<Map<String, dynamic>> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<int> insert(Map<String, dynamic> role) async {
    final Database db = await _databaseHelper.database;
    return await db.insert('roles', role);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final Database db = await _databaseHelper.database;
    return await db.query('roles');
  }

  @override
  Future<Map<String, dynamic>?> getById(int id) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'roles',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  @override
  Future<int> update(Map<String, dynamic> role) async {
    final Database db = await _databaseHelper.database;
    return await db.update(
      'roles',
      role,
      where: 'id = ?',
      whereArgs: [role['id']],
    );
  }

  @override
  Future<int> delete(int id) async {
    final Database db = await _databaseHelper.database;
    return await db.delete(
      'roles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Role-spezifische Methoden
  Future<Map<String, dynamic>?> getRoleByDescription(String roleDesc) async {
    final Database db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'roles',
      where: 'role_desc = ?',
      whereArgs: [roleDesc],
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<List<Map<String, dynamic>>> getRolesByUserId(int userId) async {
    final Database db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT r.* FROM roles r
      INNER JOIN user_roles ur ON r.id = ur.role_id
      WHERE ur.user_id = ?
    ''', [userId]);
  }

  // User-Role Verknüpfungen verwalten
  Future<int> assignRoleToUser(int userId, int roleId) async {
    final Database db = await _databaseHelper.database;
    return await db.insert('user_roles', {
      'user_id': userId,
      'role_id': roleId,
    });
  }

  Future<int> removeRoleFromUser(int userId, int roleId) async {
    final Database db = await _databaseHelper.database;
    return await db.delete(
      'user_roles',
      where: 'user_id = ? AND role_id = ?',
      whereArgs: [userId, roleId],
    );
  }

  Future<List<Map<String, dynamic>>> getUsersWithRole(int roleId) async {
    final Database db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT u.* FROM users u
      INNER JOIN user_roles ur ON u.id = ur.user_id
      WHERE ur.role_id = ?
    ''', [roleId]);
  }
}