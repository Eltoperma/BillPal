import 'package:flutter/material.dart';
import 'package:billpal/core/services/data_refresh_service.dart';

/// Mixin für automatische Daten-Aktualisierung in StatefulWidgets
/// 
/// Usage:
/// ```dart
/// class MyPage extends StatefulWidget with AutoRefreshMixin {
///   @override
///   List<String> get refreshEvents => [RefreshEvents.billsChanged];
///   
///   @override
///   void onDataRefresh() {
///     _loadData(); // Deine Reload-Logik
///   }
/// }
/// ```
mixin AutoRefreshMixin<T extends StatefulWidget> on State<T> {
  final DataRefreshService _refreshService = DataRefreshService();

  /// Override: Definiere welche Events dieses Widget refreshen sollen
  List<String> get refreshEvents;

  /// Override: Implementiere deine Reload-Logik
  void onDataRefresh();

  @override
  void initState() {
    super.initState();
    _registerRefreshListeners();
  }

  @override
  void dispose() {
    _unregisterRefreshListeners();
    super.dispose();
  }

  void _registerRefreshListeners() {
    for (final event in refreshEvents) {
      _refreshService.addListener(event, _handleRefresh);
    }
  }

  void _unregisterRefreshListeners() {
    for (final event in refreshEvents) {
      _refreshService.removeListener(event, _handleRefresh);
    }
  }

  void _handleRefresh() {
    if (mounted) {
      onDataRefresh();
    }
  }
}