import '../../logging/app_logger.dart';

/// Mock-Repository für Web-Verwendung
/// Simuliert SQLite-Verhalten im Browser
class MockBillRepository {
  static final List<Map<String, dynamic>> _bills = [];
  static int _nextId = 1;

  Future<int> insert(Map<String, dynamic> bill) async {
    AppLogger.sql.debug('🌐 MockBillRepository.insert: $bill');
    
    final billWithId = {...bill, 'id': _nextId++};
    _bills.add(billWithId);
    
    AppLogger.sql.success('🌐 Mock Bill gespeichert mit ID: ${billWithId['id']}');
    return billWithId['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    return List.from(_bills);
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      return _bills.firstWhere((bill) => bill['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<int> update(Map<String, dynamic> bill) async {
    final index = _bills.indexWhere((b) => b['id'] == bill['id']);
    if (index != -1) {
      _bills[index] = bill;
      return 1;
    }
    return 0;
  }

  Future<int> delete(int id) async {
    final index = _bills.indexWhere((bill) => bill['id'] == id);
    if (index != -1) {
      _bills.removeAt(index);
      return 1;
    }
    return 0;
  }

  /// Aktualisiert den Status einer Bill (für Web-Mock)
  Future<int> updateBillStatus(int billId, String status) async {
    AppLogger.sql.debug('🌐 MockBillRepository.updateBillStatus: $billId → $status');
    
    final index = _bills.indexWhere((bill) => bill['id'] == billId);
    if (index != -1) {
      _bills[index]['status'] = status;
      AppLogger.sql.success('🌐 Mock Bill-Status aktualisiert: $billId → $status');
      return 1;
    }
    return 0;
  }

  Future<List<Map<String, dynamic>>> getBillsByUserId(int userId) async {
    return _bills.where((bill) => bill['user_id'] == userId).toList();
  }

  Future<Map<String, dynamic>?> getBillWithPositions(int billId) async {
    final bill = await getById(billId);
    if (bill != null) {
      // Hier würden normalerweise die Positionen geladen werden
      bill['positions'] = MockPositionRepository.getPositionsByBillId(billId);
    }
    return bill;
  }
}

/// Mock-Repository für User/Personen
class MockUserRepository {
  static final List<Map<String, dynamic>> _users = [];
  static int _nextId = 1;

  Future<int> insert(Map<String, dynamic> user) async {
    AppLogger.sql.debug('🌐 MockUserRepository.insert: $user');
    
    final userWithId = {...user, 'id': _nextId++};
    _users.add(userWithId);
    
    AppLogger.sql.success('🌐 Mock User gespeichert mit ID: ${userWithId['id']}');
    return userWithId['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    return List.from(_users);
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      return _users.firstWhere((user) => user['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<int> update(Map<String, dynamic> user) async {
    final index = _users.indexWhere((u) => u['id'] == user['id']);
    if (index != -1) {
      _users[index] = user;
      return 1;
    }
    return 0;
  }

  Future<int> delete(int id) async {
    final index = _users.indexWhere((user) => user['id'] == id);
    if (index != -1) {
      _users.removeAt(index);
      return 1;
    }
    return 0;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      return _users.firstWhere((user) => user['email'] == email);
    } catch (e) {
      return null;
    }
  }
}

/// Mock-Repository für Positionen
class MockPositionRepository {
  static final List<Map<String, dynamic>> _positions = [];
  static int _nextId = 1;

  Future<int> insert(Map<String, dynamic> position) async {
    AppLogger.sql.debug('🌐 MockPositionRepository.insert: $position');
    
    final positionWithId = {...position, 'id': _nextId++};
    _positions.add(positionWithId);
    
    AppLogger.sql.success('🌐 Mock Position gespeichert mit ID: ${positionWithId['id']}');
    return positionWithId['id'] as int;
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    return List.from(_positions);
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    try {
      return _positions.firstWhere((pos) => pos['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<int> update(Map<String, dynamic> position) async {
    final index = _positions.indexWhere((p) => p['id'] == position['id']);
    if (index != -1) {
      _positions[index] = position;
      return 1;
    }
    return 0;
  }

  Future<int> delete(int id) async {
    final index = _positions.indexWhere((pos) => pos['id'] == id);
    if (index != -1) {
      _positions.removeAt(index);
      return 1;
    }
    return 0;
  }

  static List<Map<String, dynamic>> getPositionsByBillId(int billId) {
    return _positions.where((pos) => pos['bill_id'] == billId).toList();
  }

  Future<double> getTotalAmountByBillId(int billId) async {
    final positions = getPositionsByBillId(billId);
    return positions.fold<double>(0.0, (sum, pos) => sum + (pos['amount'] as double));
  }

  Future<double> getOpenAmountByUserId(int userId) async {
    final openPositions = _positions
        .where((pos) => pos['user_id'] == userId && pos['open'] == 1)
        .toList();
    return openPositions.fold<double>(0.0, (sum, pos) => sum + (pos['amount'] as double));
  }
}