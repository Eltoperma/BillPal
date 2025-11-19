import 'package:flutter/foundation.dart';

/// Zentrale Event-Namen für Data Refresh
class RefreshEvents {
  static const String billsChanged = 'bills_changed';
  static const String positionsChanged = 'positions_changed';
  static const String debtsChanged = 'debts_changed';
  static const String friendsChanged = 'friends_changed';
}

/// Zentraler Service für automatische Daten-Aktualisierung
/// Implementiert Observer Pattern für UI-Refreshs
class DataRefreshService {
  static final DataRefreshService _instance = DataRefreshService._internal();
  factory DataRefreshService() => _instance;
  DataRefreshService._internal();

  final Map<String, List<VoidCallback>> _listeners = {};

  /// Registriert einen Listener für bestimmte Events
  void addListener(String event, VoidCallback callback) {
    _listeners[event] ??= [];
    _listeners[event]!.add(callback);
  }

  /// Entfernt einen Listener
  void removeListener(String event, VoidCallback callback) {
    _listeners[event]?.remove(callback);
  }

  /// Triggert ein Event und benachrichtigt alle Listener
  void notifyDataChanged(String event) {
    if (kDebugMode) {
      print('🔄 DataRefresh: $event');
    }
    
    _listeners[event]?.forEach((callback) {
      try {
        callback();
      } catch (e) {
        if (kDebugMode) {
          print('❌ Fehler beim Data Refresh: $e');
        }
      }
    });
  }

  /// Convenience-Methoden für häufige Events
  void notifyBillsChanged() => notifyDataChanged(RefreshEvents.billsChanged);
  void notifyPositionsChanged() => notifyDataChanged(RefreshEvents.positionsChanged);
  void notifyDebtsChanged() => notifyDataChanged(RefreshEvents.debtsChanged);
  void notifyFriendsChanged() => notifyDataChanged(RefreshEvents.friendsChanged);

  /// Cleanup aller Listener
  void dispose() {
    _listeners.clear();
  }
}