import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

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
    final String path;
    
    if (kIsWeb) {
      // Web: In-Memory Database verwenden
      path = ':memory:';
      print('🗃️ SQLite DB (WEB/Memory): $path');
    } else if (kDebugMode) {
      // Desktop Debug: Projektverzeichnis verwenden
      path = join(Directory.current.path, 'dev_data', 'billpal.db');
      
      // Directory erstellen falls nicht vorhanden
      final devDataDir = Directory(join(Directory.current.path, 'dev_data'));
      if (!await devDataDir.exists()) {
        await devDataDir.create(recursive: true);
      }
      
      print('🗃️ SQLite DB (DEV): $path');
    } else {
      // Desktop/Mobile Production: App-Documents verwenden
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'billpal.db');
      print('🗃️ SQLite DB (PROD): $path');
    }
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
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
  }
}