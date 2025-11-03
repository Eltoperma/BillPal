import 'package:flutter/foundation.dart';

/// Zentrales Logging-System für BillPal
/// 
/// Usage:
/// ```dart
/// AppLogger.bills.debug('Bill loaded: ${bill.title}');
/// AppLogger.sql.info('SQLite query executed');
/// AppLogger.error('Critical error: $error');
/// ```
class AppLogger {
  final String _category;
  
  const AppLogger._(this._category);
  
  // Feature-spezifische Logger
  static const AppLogger bills = AppLogger._('BILLS');
  static const AppLogger dashboard = AppLogger._('DASHBOARD');
  static const AppLogger users = AppLogger._('USERS');
  static const AppLogger sql = AppLogger._('SQL');
  static const AppLogger ui = AppLogger._('UI');
  static const AppLogger nav = AppLogger._('NAV');
  static const AppLogger ocr = AppLogger._('OCR');
  static const AppLogger parser = AppLogger._('PARSER');
  
  // Global Logger für kritische Fehler
  static void globalError(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) print('   Error: $error');
      if (stackTrace != null) print('   Stack: $stackTrace');
    }
  }
  
  static void globalWarning(String message) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }
  
  static void globalInfo(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }
  
  // Feature-spezifische Logs
  void debug(String message) {
    if (kDebugMode) {
      print('🔍 $_category: $message');
    }
  }
  
  void info(String message) {
    if (kDebugMode) {
      print('ℹ️ $_category: $message');
    }
  }
  
  void success(String message) {
    if (kDebugMode) {
      print('✅ $_category: $message');
    }
  }
  
  void warning(String message) {
    if (kDebugMode) {
      print('⚠️ $_category: $message');
    }
  }
  
  void error(String message, [Object? error]) {
    if (kDebugMode) {
      print('❌ $_category: $message');
      if (error != null) print('   Error: $error');
    }
  }
}