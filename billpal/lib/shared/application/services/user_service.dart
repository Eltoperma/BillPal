import 'package:flutter/foundation.dart';
import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/core/app_mode/app_mode_service.dart';
import 'package:billpal/core/database/repositories/repositories.dart';
import 'package:billpal/core/database/repositories/mock_repositories.dart';
import 'package:billpal/core/logging/app_logger.dart';

/// Application Service für User/Freunde-Verwaltung
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

  /// Gibt einen User anhand der ID zurück
  Future<Person?> getUserById(int userId) async {
    if (_appMode.isDemoMode || _appMode.isUninitialized) {
      // Demo-Mode: In-Memory Suche
      final currentUser = _getDemoCurrentUser();
      if (userId == 1 || currentUser.id == userId.toString()) {
        return currentUser;
      }
      
      final friends = _getDemoFriends();
      try {
        return friends.firstWhere((friend) => 
          friend.id == userId.toString() || 
          friend.id == 'friend_${userId - 1}' // friend_1 = userId 2, etc.
        );
      } catch (e) {
        return null;
      }
    } else {
      // Real-Mode: Repository-Call
      try {
        final userData = await _userRepo.getById(userId);
        if (userData != null) {
          return Person(
            id: userData['id'].toString(),
            name: userData['name'] ?? 'Unbekannt',
            email: userData['email'],
            phone: userData['mobile'],
            createdAt: DateTime.now(),
          );
        }
        return null;
      } catch (e) {
        AppLogger.users.error('Fehler beim Laden des Users $userId: $e');
        return null;
      }
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
        AppLogger.users.error('Fehler beim Laden der Freunde: $e');
        return [];
      }
    }
  }

  /// Fügt einen neuen Freund hinzu
  Future<Person> addFriend({
    required String name,
    String? email,
    String? phone,
  }) async {
    final newFriend = Person(
      id: 'friend_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      createdAt: DateTime.now(),
    );

    if (_appMode.isDemoMode || _appMode.isUninitialized) {
      _getDemoFriends().add(newFriend);
      AppLogger.users.success('Demo-Freund hinzugefügt: ${newFriend.name}');
    } else {
      try {
        AppLogger.users.info('🏠 UserService.addFriend: Real-Mode - Repository-Call');
        await _userRepo.insert({
          'name': name,
          'email': email,
          'mobile': phone,
        });
        AppLogger.users.success('Real-Freund hinzugefügt: $name');
      } catch (e) {
        AppLogger.users.error('Fehler beim Hinzufügen des Freundes: $e');
        throw e;
      }
    }
    
    return newFriend;
  }

  /// Entfernt einen Freund
  Future<bool> removeFriend(String friendId) async {
    if (_appMode.isDemoMode || _appMode.isUninitialized) {
      _getDemoFriends().removeWhere((friend) => friend.id == friendId);
      AppLogger.users.success('Demo-Freund entfernt: $friendId');
      return true;
    } else {
      try {
        AppLogger.users.info('🏠 UserService.removeFriend: Real-Mode - Repository-Call');
        await _userRepo.delete(int.parse(friendId));
        AppLogger.users.success('Real-Freund entfernt: $friendId');
        return true;
      } catch (e) {
        AppLogger.users.error('Fehler beim Entfernen des Freundes: $e');
        return false;
      }
    }
  }

  /// Sucht Freunde nach Name
  Future<List<Person>> searchFriends(String query) async {
    final allFriends = await getAllFriends();
    if (query.isEmpty) return allFriends;
    
    return allFriends.where((friend) =>
      friend.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Demo-Daten
  Person _getDemoCurrentUser() {
    return _demoCurrentUser ??= Person(
      id: 'current_user',
      name: 'Ich',
      email: 'ich@example.com',
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
    );
  }

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