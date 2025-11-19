import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../logging/app_logger.dart';

/// Repository für User-Category-Daten (Keywords und Korrekturen)
class UserCategoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // --- USER KEYWORDS ---

  /// Fügt ein User-Keyword hinzu
  Future<int> insertUserKeyword({
    required int userId,
    required String categoryId,
    required String keyword,
    required String locale,
  }) async {
    final Database db = await _databaseHelper.database;
    
    try {
      return await db.insert('user_category_keywords', {
        'user_id': userId,
        'category_id': categoryId,
        'keyword': keyword.toLowerCase().trim(),
        'locale': locale,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        AppLogger.sql.debug('Keyword "$keyword" bereits vorhanden für Kategorie $categoryId');
        return 0; // Kein Fehler, nur bereits vorhanden
      }
      rethrow;
    }
  }

  /// Holt alle User-Keywords für eine Kategorie und Sprache
  Future<List<String>> getUserKeywords({
    required int userId,
    required String categoryId,
    required String locale,
  }) async {
    final Database db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'user_category_keywords',
      columns: ['keyword'],
      where: 'user_id = ? AND category_id = ? AND locale = ?',
      whereArgs: [userId, categoryId, locale],
      orderBy: 'created_at DESC',
    );
    
    return maps.map((map) => map['keyword'] as String).toList();
  }

  /// Entfernt ein User-Keyword
  Future<int> removeUserKeyword({
    required int userId,
    required String categoryId,
    required String keyword,
    required String locale,
  }) async {
    final Database db = await _databaseHelper.database;
    
    return await db.delete(
      'user_category_keywords',
      where: 'user_id = ? AND category_id = ? AND keyword = ? AND locale = ?',
      whereArgs: [userId, categoryId, keyword.toLowerCase().trim(), locale],
    );
  }

  // --- USER CORRECTIONS ---

  /// Fügt eine User-Korrektur hinzu
  Future<int> insertUserCorrection({
    required int userId,
    required String billTitle,
    required String originalCategory,
    required String correctedCategory,
    required String locale,
  }) async {
    final Database db = await _databaseHelper.database;
    
    return await db.insert('user_category_corrections', {
      'user_id': userId,
      'bill_title': billTitle,
      'original_category': originalCategory,
      'corrected_category': correctedCategory,
      'locale': locale,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Holt alle User-Korrekturen
  Future<List<Map<String, dynamic>>> getUserCorrections({
    required int userId,
  }) async {
    final Database db = await _databaseHelper.database;
    
    return await db.query(
      'user_category_corrections',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  /// Entfernt eine User-Korrektur
  Future<int> removeUserCorrection({
    required int correctionId,
  }) async {
    final Database db = await _databaseHelper.database;
    
    return await db.delete(
      'user_category_corrections',
      where: 'id = ?',
      whereArgs: [correctionId],
    );
  }

  /// Holt alle Keywords die aus Korrekturen gelernt werden können
  Future<List<Map<String, dynamic>>> getLearnableKeywords({
    required int userId,
    required String locale,
  }) async {
    final Database db = await _databaseHelper.database;
    
    // SQL um aus Korrekturen Keywords zu extrahieren
    return await db.rawQuery('''
      SELECT 
        corrected_category,
        bill_title,
        COUNT(*) as frequency
      FROM user_category_corrections 
      WHERE user_id = ? AND locale = ?
      GROUP BY corrected_category, bill_title
      ORDER BY frequency DESC
    ''', [userId, locale]);
  }
}