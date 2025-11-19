import 'package:flutter/foundation.dart';
import '../../core/database/repositories/repositories.dart';
import '../../core/database/repositories/mock_repositories.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/data_refresh_service.dart';

/// Service für Bill-Operationen mit Business-Logik
/// Koordiniert mehrere Repositories und verwaltet Transaktionen
class BillService {
  // Web: Mock-Repositories, Desktop: Echte Repositories
  late final dynamic _billRepository;
  late final dynamic _positionRepository;
  final DataRefreshService _refreshService = DataRefreshService();

  BillService() {
    if (kIsWeb) {
      AppLogger.sql.info('🌐 Verwende Mock-Repositories für Web');
      _billRepository = MockBillRepository();
      _positionRepository = MockPositionRepository();
    } else {
      AppLogger.sql.info('🖥️ Verwende echte SQLite-Repositories');
      _billRepository = BillRepository();
      _positionRepository = PositionRepository();
    }
  }

  /// Speichert eine komplette Rechnung mit allen Positionen
  /// Nimmt InvoiceData aus der Form und speichert in DB
  Future<int> saveInvoiceData({
    required String title,
    required DateTime dateTime,
    required int userId, // Der User der die Rechnung erstellt
    required List<LineItemData> lineItems,
    String? picturePath,
  }) async {
    
    AppLogger.bills.info('🔵 BillService.saveInvoiceData gestartet');
    AppLogger.bills.debug('🔵 Titel: "$title"');
    AppLogger.bills.debug('🔵 UserId: $userId');
    AppLogger.bills.debug('🔵 LineItems: ${lineItems.length}');
    
    // 1. Validierung
    if (title.trim().isEmpty) {
      AppLogger.bills.error('❌ Titel ist leer');
      throw Exception('Titel darf nicht leer sein');
    }
    if (lineItems.isEmpty) {
      AppLogger.bills.error('❌ Keine LineItems');
      throw Exception('Mindestens ein LineItem erforderlich');
    }
    
    AppLogger.bills.success('✅ Validierung OK');
    
    // 2. Bill erstellen
    final billData = {
      'title': title.trim(),
      'date': dateTime.toIso8601String(),
      'user_id': userId,
      'pic': picturePath,
    };
    
    AppLogger.sql.debug('🔵 Erstelle Bill mit: $billData');
    late final int billId;
    try {
      billId = await _billRepository.insert(billData);
      AppLogger.sql.success('✅ Bill erstellt mit ID: $billId');
    } catch (e, stackTrace) {
      AppLogger.sql.error('❌ FEHLER beim Bill-Insert: $e');
      AppLogger.sql.error('📍 StackTrace: $stackTrace');
      rethrow; // Exception weiterwerfen
    }
    
    // 3. Alle Positionen speichern
    AppLogger.bills.info('🔵 Speichere ${lineItems.length} Positionen...');
    for (int i = 0; i < lineItems.length; i++) {
      final item = lineItems[i];
      AppLogger.bills.debug('🔵 Position ${i+1}: "${item.description}" - ${item.amount}€');
      
      if (item.description.trim().isEmpty || 
          item.amount <= 0 || 
          item.assigneeUserId == null) {
        AppLogger.bills.debug('⚠️ Position ${i+1} übersprungen (ungültig)');
        continue; // Überspringe ungültige Items
      }
      
      final positionData = {
        'desc': item.description.trim(),
        'amount': item.amount,
        'currency': item.currency ?? 'EUR',
        'open': item.isOpen ? 1 : 0, // boolean zu int
        'bill_id': billId,
        'user_id': item.assigneeUserId!,
      };
      
      AppLogger.sql.debug('🔵 Speichere Position: $positionData');
      try {
        await _positionRepository.insert(positionData);
        AppLogger.sql.success('✅ Position ${i+1} gespeichert');
      } catch (e, stackTrace) {
        AppLogger.sql.error('❌ FEHLER beim Position-Insert: $e');
        AppLogger.sql.error('📍 StackTrace: $stackTrace');
        rethrow;
      }
    }
    
    AppLogger.bills.success('🎉 Alle Daten erfolgreich gespeichert! Bill-ID: $billId');
    
    // UI Refresh triggern nach Bill-Erstellung
    _refreshService.notifyBillsChanged();
    _refreshService.notifyDebtsChanged();
    
    return billId;
  }

  /// Lädt eine komplette Rechnung mit allen Positionen
  Future<Map<String, dynamic>?> getCompleteInvoice(int billId) async {
    return await _billRepository.getBillWithPositions(billId);
  }

  /// Lädt alle Rechnungen eines Users
  Future<List<Map<String, dynamic>>> getUserInvoices(int userId) async {
    return await _billRepository.getBillsByUserId(userId);
  }

  /// Berechnet die Gesamtsumme einer Rechnung
  Future<double> getInvoiceTotal(int billId) async {
    return await _positionRepository.getTotalAmountByBillId(billId);
  }

  /// Lädt alle offenen Beträge eines Users
  Future<double> getUserOpenAmount(int userId) async {
    return await _positionRepository.getOpenAmountByUserId(userId);
  }

  /// Markiert eine Position als bezahlt/offen
  Future<void> togglePositionStatus(int positionId) async {
    final position = await _positionRepository.getById(positionId);
    if (position != null) {
      final newOpenStatus = position['open'] == 1 ? 0 : 1;
      final updatedPosition = Map<String, dynamic>.from(position);
      updatedPosition['open'] = newOpenStatus;
      
      await _positionRepository.update(updatedPosition);
    }
  }

  /// Löscht eine komplette Rechnung mit allen Positionen
  Future<void> deleteInvoice(int billId) async {
    // Erst alle Positionen löschen
    final positions = await _positionRepository.getPositionsByBillId(billId);
    for (final position in positions) {
      await _positionRepository.delete(position['id']);
    }
    
    // Dann die Rechnung löschen
    await _billRepository.delete(billId);
  }
}

/// Daten-Klasse für LineItems beim Speichern
class LineItemData {
  final String description;
  final double amount;
  final String? currency;
  final bool isOpen;
  final int? assigneeUserId;

  LineItemData({
    required this.description,
    required this.amount,
    this.currency = 'EUR',
    this.isOpen = true,
    required this.assigneeUserId,
  });
}