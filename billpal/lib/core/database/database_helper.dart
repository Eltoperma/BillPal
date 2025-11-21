import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../logging/app_logger.dart';

/// Zentrale Datenbankklasse für die BillPal App
/// Erstellt und verwaltet das SQLite-Schema basierend auf dem ERD
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  /// Singleton-Zugriff auf die Datenbank
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialisiert die SQLite-Datenbank
  Future<Database> _initDatabase() async {
    String path;
    
    if (kIsWeb) {
      // Web: In-Memory Database verwenden
      path = ':memory:';
      AppLogger.sql.info('🗃️ SQLite DB (WEB/Memory): $path');
    } else if (kDebugMode && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      // Desktop Debug: Projektverzeichnis verwenden (nur auf Desktop-Plattformen)
      try {
        path = join(Directory.current.path, 'dev_data', 'billpal.db');
        
        // Directory erstellen falls nicht vorhanden
        final devDataDir = Directory(join(Directory.current.path, 'dev_data'));
        if (!await devDataDir.exists()) {
          await devDataDir.create(recursive: true);
        }
        
        AppLogger.sql.info('🗃️ SQLite DB (DESKTOP-DEV): $path');
      } catch (e) {
        // Fallback zu App Documents wenn Desktop-Pfad nicht funktioniert
        final Directory documentsDirectory = await getApplicationDocumentsDirectory();
        path = join(documentsDirectory.path, 'billpal_dev.db');
        AppLogger.sql.info('🗃️ SQLite DB (FALLBACK-DEV): $path');
      }
    } else {
      // Mobile/Desktop Production: App-Documents verwenden
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final dbName = kDebugMode ? 'billpal_debug.db' : 'billpal.db';
      path = join(documentsDirectory.path, dbName);
      AppLogger.sql.info('🗃️ SQLite DB (${kDebugMode ? 'MOBILE-DEV' : 'PROD'}): $path');
    }
    
    return await openDatabase(
      path,
      version: 3, // Version erhöht für Bill-Status-Feld
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  /// Erstellt alle Datenbanktabellen gemäß ERD
  Future<void> _createTables(Database db, int version) async {
    
    // users Tabelle
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        mobile TEXT,
        email TEXT
      )
    ''');

    // roles Tabelle  
    await db.execute('''
      CREATE TABLE roles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role_desc TEXT NOT NULL
      )
    ''');

    // bills Tabelle
    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        pic TEXT,
        status TEXT NOT NULL DEFAULT 'shared',
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // positions Tabelle
    await db.execute('''
      CREATE TABLE positions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        desc TEXT,
        amount REAL NOT NULL,
        currency TEXT,
        open INTEGER NOT NULL DEFAULT 1,
        bill_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (bill_id) REFERENCES bills (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // user_roles Verknüpfungstabelle (Many-to-Many zwischen users und roles)
    await db.execute('''
      CREATE TABLE user_roles (
        user_id INTEGER NOT NULL,
        role_id INTEGER NOT NULL,
        PRIMARY KEY (user_id, role_id),
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (role_id) REFERENCES roles (id)
      )
    ''');

    // user_category_keywords - User-definierte Keywords für Kategorien
    await db.execute('''
      CREATE TABLE user_category_keywords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        category_id TEXT NOT NULL,
        keyword TEXT NOT NULL,
        locale TEXT NOT NULL DEFAULT 'de',
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        UNIQUE(user_id, category_id, keyword, locale)
      )
    ''');

    // user_category_corrections - User-Korrekturen der automatischen Kategorisierung
    await db.execute('''
      CREATE TABLE user_category_corrections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        bill_title TEXT NOT NULL,
        original_category TEXT NOT NULL,
        corrected_category TEXT NOT NULL,
        locale TEXT NOT NULL DEFAULT 'de',
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  /// Führt Datenbank-Migrationen durch
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.sql.info('📈 Database Migration: v$oldVersion → v$newVersion');
    
    if (oldVersion < 2) {
      // Migration zu Version 2: User-Category Tabellen hinzufügen
      AppLogger.sql.info('➕ Füge User-Category Tabellen hinzu...');
      
      await db.execute('''
        CREATE TABLE user_category_keywords (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          category_id TEXT NOT NULL,
          keyword TEXT NOT NULL,
          locale TEXT NOT NULL DEFAULT 'de',
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id),
          UNIQUE(user_id, category_id, keyword, locale)
        )
      ''');

      await db.execute('''
        CREATE TABLE user_category_corrections (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          bill_title TEXT NOT NULL,
          original_category TEXT NOT NULL,
          corrected_category TEXT NOT NULL,
          locale TEXT NOT NULL DEFAULT 'de',
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');
      
      AppLogger.sql.success('✅ User-Category Tabellen erfolgreich hinzugefügt');
    }
    
    if (oldVersion < 3) {
      // Migration zu Version 3: Bill-Status-Feld hinzufügen
      AppLogger.sql.info('➕ Füge Status-Feld zu Bills-Tabelle hinzu...');
      
      await db.execute('''
        ALTER TABLE bills ADD COLUMN status TEXT NOT NULL DEFAULT 'shared'
      ''');
      
      AppLogger.sql.success('✅ Bill-Status-Feld erfolgreich hinzugefügt');
    }
  }
}