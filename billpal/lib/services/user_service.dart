import 'package:flutter/foundation.dart';
import 'package:billpal/models/invoice.dart';
import 'package:billpal/core/app_mode/app_mode_service.dart';
import 'package:billpal/core/database/repositories/repositories.dart';
import 'package:billpal/core/database/repositories/mock_repositories.dart';
import 'package:billpal/core/logging/app_logger.dart';

/// Zentraler Service für User/Freunde-Verwaltung
/// Einheitliche Demo/Real Logik für alle Freunde-bezogenen Operationen
/// 
/// TODO: [CLEANUP] Nach vollständiger Migration Mock-Logik entfernen
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal() {
    _userRepo = kIsWeb ? MockUserRepository() : UserRepository();
  }

  late final dynamic _userRepo; // Mock oder Real Repository
  final AppModeService _appMode = AppModeService();
  
  // Demo-Daten Cache (nur für Demo-Mode)
  List<Person>? _demoFriends;
  Person? _demoCurrentUser;

  /// Gibt den aktuellen Benutzer zurück
  Future<Person> getCurrentUser() async {
    if (_appMode.isDemoMode || _appMode.isUninitialized) {
      return _getDemoCurrentUser();
    } else {
      // TODO: [CLEANUP] Echte User-Abfrage implementieren
      return _getDemoCurrentUser(); // Temporär noch Demo
    }
  }

  /// Gibt alle Freunde zurück
  Future<List<Person>> getAllFriends() async {
    if (_appMode.isDemoMode || _appMode.isUninitialized) {
      return _getDemoFriends();
    } else {
      try {
        AppLogger.users.info('🏠 UserService.getAllFriends: Real-Mode - Repository-Call');
        final users = await _userRepo.getAll();
        return users.map<Person>((userData) => Person(
          id: userData['id'].toString(),
          name: userData['name'] ?? 'Unbekannt',
          email: userData['email'],
          phone: userData['mobile'], // SQLite verwendet 'mobile' nicht 'phone'
          createdAt: DateTime.now(), // SQLite hat kein created_at Feld
        )).toList();
      } catch (e) {
        AppLogger.users.error('⚠️ UserService: Fehler beim Laden der Real-Freunde: $e');
        // Fallback auf Demo-Daten
        return _getDemoFriends();
      }
    }
  }

  /// Freund hinzufügen
  Future<Person> addFriend({
    required String name,
    String? email,
    String? phone,
  }) async {
    final newFriend = Person(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      createdAt: DateTime.now(),
    );

    if (_appMode.isDemoMode) {
      AppLogger.users.info('🎭 UserService.addFriend: Demo-Mode - In-Memory hinzufügen');
      _demoFriends?.add(newFriend);
      return newFriend;
    } else {
      try {
        AppLogger.users.info('🏠 UserService.addFriend: Real-Mode - Repository-Call');
        final friendData = {
          'name': newFriend.name,
          'email': newFriend.email,
          'mobile': newFriend.phone,
        };
        await _userRepo.insert(friendData);
        return newFriend;
      } catch (e) {
        AppLogger.users.error('⚠️ UserService: Fehler beim Hinzufügen des Real-Freundes: $e');
        // Fallback to demo
        _demoFriends?.add(newFriend);
        return newFriend;
      }
    }
  }

  /// Freund löschen
  Future<bool> removeFriend(String friendId) async {
    if (_appMode.isDemoMode || _appMode.isUninitialized) {
      AppLogger.users.info('🎭 UserService.removeFriend: Demo-Mode - Aus Memory entfernen');
      _demoFriends?.removeWhere((friend) => friend.id == friendId);
      return true;
    } else {
      try {
        AppLogger.users.info('🏠 UserService.removeFriend: Real-Mode - Repository-Call');
        final result = await _userRepo.delete(int.parse(friendId));
        return result > 0;
      } catch (e) {
        AppLogger.users.error('⚠️ UserService: Fehler beim Löschen des Real-Freundes: $e');
        return false;
      }
    }
  }

  /// Freunde nach Namen suchen
  Future<List<Person>> searchFriends(String query) async {
    final allFriends = await getAllFriends();
    final lowerQuery = query.toLowerCase();
    
    return allFriends.where((friend) =>
      friend.name.toLowerCase().contains(lowerQuery) ||
      (friend.email?.toLowerCase().contains(lowerQuery) ?? false)
    ).toList();
  }

  /// Demo-Daten: Aktueller Benutzer
  Person _getDemoCurrentUser() {
    return _demoCurrentUser ??= Person(
      id: 'user_me',
      name: 'Ich',
      email: 'me@example.com',
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
    );
  }

  /// Demo-Daten: Freunde-Liste
  List<Person> _getDemoFriends() {
    return _demoFriends ??= _createDemoFriends();
  }

  /// TODO: [CLEANUP] Diese Demo-Daten aus invoice_service.dart hierher migriert
  List<Person> _createDemoFriends() {
    return [
      Person(
        id: 'friend_1',
        name: 'Anna',
        email: 'anna@example.com',
        createdAt: DateTime.now().subtract(const Duration(days: 80)),
      ),
      Person(
        id: 'friend_2',
        name: 'Max',
        phone: '+49123456789',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      Person(
        id: 'friend_3',
        name: 'Lisa',
        email: 'lisa@example.com',
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
      Person(
        id: 'friend_4',
        name: 'Tom',
        phone: '+49987654321',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Person(
        id: 'friend_5',
        name: 'Sarah',
        email: 'sarah@example.com',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Person(
        id: 'friend_6',
        name: 'Tim',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  /// Reset für Testing
  void resetForTesting() {
    _demoFriends = null;
    _demoCurrentUser = null;
  }

  /// Debug-Info
  String getDebugInfo() {
    return '''
🔧 UserService Debug Info:
- App Mode: ${_appMode.currentMode.name}
- Demo Friends Loaded: ${_demoFriends?.length ?? 0}
- Repository Type: ${kIsWeb ? 'Mock' : 'SQLite'}
''';
  }
}