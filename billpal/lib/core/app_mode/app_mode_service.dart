import 'package:flutter/foundation.dart';
import 'package:billpal/core/database/repositories/repositories.dart';
import 'package:billpal/core/database/repositories/mock_repositories.dart';

/// Zentraler Service für Demo/Real Mode Management
/// 
/// TODO: [CLEANUP] Nach vollständiger UI-Implementierung entfernen
/// und direkt auf Real-Mode umstellen (Ende dieses Branches)
class AppModeService {
  static final AppModeService _instance = AppModeService._internal();
  factory AppModeService() => _instance;
  AppModeService._internal() {
    // Repository basierend auf Platform initialisieren
    _userRepo = kIsWeb ? MockUserRepository() : UserRepository();
  }
  
  AppMode _currentMode = AppMode.uninitialized;
  late final dynamic _userRepo; // dynamic wegen unterschiedlicher Typen

  AppMode get currentMode => _currentMode;
  bool get isDemoMode => _currentMode == AppMode.demo;
  bool get isRealMode => _currentMode == AppMode.real;
  bool get isUninitialized => _currentMode == AppMode.uninitialized;

  /// Smart Detection: Erkennt automatisch ob erste App-Nutzung
  Future<AppMode> detectInitialMode() async {
    try {
      // Prüfe ob bereits echte Benutzer existieren
      final hasRealUsers = await _hasExistingRealUsers();
      
      if (hasRealUsers) {
        _currentMode = AppMode.real;
        print('🏠 AppMode: Real-Mode erkannt (bestehende Benutzer gefunden)');
      } else {
        _currentMode = AppMode.demo;
        print('🎭 AppMode: Demo-Mode aktiviert (erste App-Nutzung)');
      }
      
      return _currentMode;
    } catch (e) {
      print('⚠️ AppMode: Fehler bei Detection, fallback zu Demo-Mode: $e');
      _currentMode = AppMode.demo;
      return _currentMode;
    }
  }

  /// Manueller Wechsel zu Real-Mode (wird von Welcome-Screen aufgerufen)
  Future<void> switchToRealMode() async {
    print('🔄 AppMode: Wechsel von ${_currentMode.name} zu Real-Mode');
    _currentMode = AppMode.real;
    
    // TODO: [CLEANUP] Preference-Storage entfernen wenn nicht mehr nötig
    // Hier könnte später SharedPreferences gespeichert werden
  }

  /// Manueller Wechsel zu Demo-Mode (für Testing/Development)
  Future<void> switchToDemoMode() async {
    print('🔄 AppMode: Wechsel von ${_currentMode.name} zu Demo-Mode');
    _currentMode = AppMode.demo;
  }

  /// Reset für Testing
  void resetForTesting() {
    _currentMode = AppMode.uninitialized;
  }

  /// Prüft ob echte Benutzer in der Datenbank existieren
  Future<bool> _hasExistingRealUsers() async {
    if (kIsWeb) {
      // Auf Web gibt es keine "echten" persistenten Daten
      // TODO: [CLEANUP] Später IndexedDB prüfen
      return false;
    }
    
    try {
      final users = await _userRepo.getAll();
      return users.isNotEmpty;
    } catch (e) {
      print('⚠️ AppMode: Fehler beim Prüfen der Real-Users: $e');
      return false;
    }
  }

  /// Debug-Info für Development
  String getDebugInfo() {
    return '''
🔧 AppMode Debug Info:
- Current Mode: ${_currentMode.name}
- Is Web: ${kIsWeb}
- Is Demo: $isDemoMode
- Is Real: $isRealMode
- Is Uninitialized: $isUninitialized
''';
  }
}

/// App-Modi für Demo/Real Switch
/// 
/// TODO: [CLEANUP] Nach vollständiger Migration entfernen
enum AppMode {
  uninitialized,  // App gerade gestartet, Mode noch nicht bestimmt
  demo,          // Demo-Modus mit Mock-Daten
  real,          // Real-Modus mit echter Persistenz
}

extension AppModeExtension on AppMode {
  String get name {
    switch (this) {
      case AppMode.uninitialized:
        return 'Uninitialized';
      case AppMode.demo:
        return 'Demo';
      case AppMode.real:
        return 'Real';
    }
  }

  String get description {
    switch (this) {
      case AppMode.uninitialized:
        return 'App-Modus wird ermittelt...';
      case AppMode.demo:
        return 'Demo-Modus mit Beispieldaten';
      case AppMode.real:
        return 'Vollversion mit echten Daten';
    }
  }
}