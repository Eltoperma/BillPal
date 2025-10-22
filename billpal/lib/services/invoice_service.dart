import 'dart:math';
import 'package:billpal/models/invoice.dart';
import 'package:billpal/core/app_mode/app_mode_service.dart';
import 'package:billpal/services/user_service.dart';
import 'package:billpal/features/bills/bill_service.dart';
import 'package:billpal/core/logging/app_logger.dart';

/// Service für die Verwaltung von geteilten Rechnungen zwischen Freunden
/// 
/// TODO: [CLEANUP] Nach vollständiger Migration Demo-Logik entfernen
/// und durch echte Repository-Pattern ersetzen (Ende dieses Branches)
class BillSharingService {
  static final BillSharingService _instance = BillSharingService._internal();
  factory BillSharingService() => _instance;
  BillSharingService._internal();

  final UserService _userService = UserService(); // Zentrale User-Verwaltung
  final List<SharedBill> _sharedBills = [];
  final Random _random = Random();

  /// Initialisiert den Service mit Demo-Daten oder lädt echte Rechnungen
  /// 
  /// TODO: [CLEANUP] Diese Methode entfernen und durch echte Repository-Calls ersetzen
  Future<void> initializeDemoData() async {
    final appMode = AppModeService();
    
    if (appMode.isDemoMode || appMode.isUninitialized) {
      AppLogger.bills.info('Demo-Daten werden geladen (Mode: ${appMode.currentMode.name})');
      _sharedBills.clear();
      
      // Erstelle Demo-Rechnungen (Freunde werden vom UserService verwaltet)
      await _createDemoSharedBills();
    } else {
      AppLogger.bills.info('Real-Mode aktiv - Mock-Daten löschen, nur echte Rechnungen');
      _sharedBills.clear(); // Demo-Rechnungen entfernen im Real-Mode
      AppLogger.bills.debug('Mock-Rechnungen entfernt, nur echte SQLite-Daten werden geladen');
      // Echte Rechnungen werden über getAllSharedBills() aus SQLite geladen
    }
  }

  Future<void> _createDemoSharedBills() async {
    final now = DateTime.now();
    final events = [
      'Restaurant Tante Emma',
      'Bowling Abend',
      'Pizzaservice',
      'Supermarkt Einkauf',
      'Bar "Zur Ecke"',
      'Kino',
      'Tankstelle',
      'Café Extrablatt',
    ];

    // Erstelle verschiedene geteilte Rechnungen
    for (int i = 0; i < 8; i++) {
      final daysAgo = _random.nextInt(30) + 1;
      final event = events[i];
      final totalAmount = 15.0 + _random.nextDouble() * 80.0; // 15€ - 95€
      
      // Zufällige Gruppe von Freunden für diese Rechnung
      final involvedFriends = await _getRandomFriends(2 + _random.nextInt(3)); // 2-4 Freunde
      final paidBy = involvedFriends[_random.nextInt(involvedFriends.length)];
      
      final bill = SharedBill(
        id: 'bill_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: event,
        description: _getDescriptionForEvent(event),
        totalAmount: double.parse(totalAmount.toStringAsFixed(2)),
        date: now.subtract(Duration(days: daysAgo)),
        eventName: '$event ${_formatEventDate(now.subtract(Duration(days: daysAgo)))}',
        paidBy: paidBy,
        items: _createItemsForBill(event, totalAmount, involvedFriends),
        status: _random.nextDouble() > 0.3 ? BillStatus.shared : BillStatus.settled,
        createdAt: now.subtract(Duration(days: daysAgo)),
      );
      
      _sharedBills.add(bill);
    }
  }

  Future<List<Person>> _getRandomFriends(int count) async {
    final currentUser = await _userService.getCurrentUser();
    final friends = await _userService.getAllFriends();
    final allPeople = [currentUser, ...friends];
    final shuffled = List<Person>.from(allPeople)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  String _getDescriptionForEvent(String event) {
    switch (event) {
      case 'Restaurant Tante Emma':
        return 'Gemeinsames Abendessen';
      case 'Bowling Abend':
        return 'Bowling + Getränke';
      case 'Pizzaservice':
        return 'Pizza bestellt';
      case 'Supermarkt Einkauf':
        return 'Einkauf für WG-Party';
      case 'Bar "Zur Ecke"':
        return 'Cocktails nach der Arbeit';
      case 'Kino':
        return 'Tickets + Popcorn';
      case 'Tankstelle':
        return 'Benzin für Roadtrip';
      case 'Café Extrablatt':
        return 'Kaffee und Kuchen';
      default:
        return 'Gemeinsame Ausgabe';
    }
  }

  String _formatEventDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  List<BillItem> _createItemsForBill(String event, double totalAmount, List<Person> people) {
    switch (event) {
      case 'Restaurant Tante Emma':
        return [
          BillItem(
            id: 'item_1',
            name: 'Hauptgerichte',
            amount: totalAmount * 0.7,
            sharedWith: people,
          ),
          BillItem(
            id: 'item_2',
            name: 'Getränke',
            amount: totalAmount * 0.3,
            sharedWith: people,
          ),
        ];
      case 'Pizzaservice':
        return [
          BillItem(
            id: 'item_1',
            name: 'Pizza Margherita',
            amount: 8.50,
            sharedWith: people.take(2).toList(),
          ),
          BillItem(
            id: 'item_2',
            name: 'Pizza Salami',
            amount: 9.50,
            sharedWith: people.skip(1).take(2).toList(),
          ),
          BillItem(
            id: 'item_3',
            name: 'Liefergebühr',
            amount: totalAmount - 18.0,
            sharedWith: people,
          ),
        ];
      case 'Supermarkt Einkauf':
        return [
          BillItem(
            id: 'item_1',
            name: 'Getränke',
            amount: totalAmount * 0.6,
            sharedWith: people,
          ),
          BillItem(
            id: 'item_2',
            name: 'Snacks',
            amount: totalAmount * 0.4,
            sharedWith: people,
          ),
        ];
      default:
        return [
          BillItem(
            id: 'item_1',
            name: event,
            amount: totalAmount,
            sharedWith: people,
          ),
        ];
    }
  }

  /// Gibt alle Freunde zurück
  /// 
  /// TODO: [CLEANUP] Durch echte Repository-Calls ersetzen
  Future<List<Person>> getAllFriends() async {
    return await _userService.getAllFriends();
  }

  /// Gibt den aktuellen Benutzer zurück
  Future<Person> getCurrentUser() async {
    return await _userService.getCurrentUser();
  }

  /// Gibt alle geteilten Rechnungen zurück
  Future<List<SharedBill>> getAllSharedBills() async {
    final appMode = AppModeService();
    
    if (appMode.isRealMode) {
      AppLogger.sql.info('Real-Mode - Lade aus SQLite');
      
      // Kombiniere In-Memory + SQLite Rechnungen
      final sqliteBills = await _loadSharedBillsFromSQLite();
      final allBills = [..._sharedBills, ...sqliteBills];
      
      AppLogger.bills.debug('${_sharedBills.length} In-Memory + ${sqliteBills.length} SQLite = ${allBills.length} total');
      return List.unmodifiable(allBills);
    } else {
      AppLogger.bills.info('Demo-Mode - ${_sharedBills.length} Demo-Rechnungen');
      return List.unmodifiable(_sharedBills);
    }
  }

  /// Lädt Rechnungen aus SQLite und konvertiert zu SharedBill
  Future<List<SharedBill>> _loadSharedBillsFromSQLite() async {
    try {
      final billService = BillService();
      final currentUser = await getCurrentUser();
      
      // Alle Rechnungen des aktuellen Users laden
      final userIdInt = int.tryParse(currentUser.id) ?? 1;
      final rawBills = await billService.getUserInvoices(userIdInt);
      
      AppLogger.sql.info('SQLite Rechnungen gefunden: ${rawBills.length}');
      for (final bill in rawBills) {
        AppLogger.sql.debug('SQLite Bill: ID=${bill['id']}, Title="${bill['title']}", Date=${bill['date']}');
      }
      
      final List<SharedBill> sharedBills = [];
      for (int i = 0; i < rawBills.length; i++) {
        final rawBill = rawBills[i];
        try {
          AppLogger.sql.debug('Konvertiere Bill ${i+1}/${rawBills.length}: ID=${rawBill['id']}');
          final sharedBill = await _convertToSharedBill(rawBill, billService);
          sharedBills.add(sharedBill);
          AppLogger.sql.success('Bill ${rawBill['id']} erfolgreich konvertiert: "${sharedBill.title}"');
        } catch (e, stackTrace) {
          AppLogger.sql.error('Fehler beim Konvertieren von Bill ID ${rawBill['id']}: $e', e);
          AppLogger.sql.error('StackTrace: $stackTrace');
        }
      }
      
      AppLogger.sql.success('SQLite-Konvertierung abgeschlossen: ${sharedBills.length}/${rawBills.length} erfolgreich');
      return sharedBills;
    } catch (e, stackTrace) {
      AppLogger.sql.error('FEHLER beim Laden aus SQLite: $e', e);
      AppLogger.sql.error('StackTrace: $stackTrace');
      return [];
    }
  }

  /// Konvertiert SQLite-Bill zu SharedBill
  Future<SharedBill> _convertToSharedBill(Map<String, dynamic> rawBill, BillService billService) async {
    final billId = rawBill['id'] as int;
    AppLogger.sql.debug('Konvertiere Bill ID $billId: "${rawBill['title']}"');
    
    try {
      // Lade echte Gesamtsumme aus der Datenbank
      final realTotal = await billService.getInvoiceTotal(billId);
      AppLogger.sql.debug('Echte Gesamtsumme für Bill $billId: $realTotal€');
      
      // App-User Logic: DU erstellst Rechnung → DU hast bezahlt → DIR wird geschuldet
      final paidBy = await getCurrentUser(); // Immer der aktuelle App-User
      
      AppLogger.sql.debug('Rechnung bezahlt von: ${paidBy.name} (App-User)');
      
      // Lade echte Positionen und Personen
      final completeInvoice = await billService.getCompleteInvoice(billId);
      final positions = completeInvoice?['positions'] as List<Map<String, dynamic>>? ?? [];
      
      AppLogger.sql.debug('Gefundene Positionen: ${positions.length}');
      
      final items = <BillItem>[];
      final allInvolvedPeople = <Person>{paidBy}; // Set für eindeutige Personen
      
      for (final pos in positions) {
        final posAmount = (pos['amount'] as num).toDouble();
        final userId = pos['user_id'] as int;
        
        // Finde Person für diese Position  
        final assignedPerson = await _findPersonByUserId(userId);
        if (assignedPerson != null) {
          allInvolvedPeople.add(assignedPerson);
          
          // App-User Logic: 
          // - paidBy = App-User (DU hast bezahlt)
          // - sharedWith = assignedPerson (WER schuldet für diesen Posten)
          
          items.add(BillItem(
            id: 'pos_${pos['id']}',
            name: pos['desc'] ?? 'Position',
            amount: posAmount,
            sharedWith: [assignedPerson], // Schuldner für diesen Posten
          ));
          
          if (assignedPerson.id == paidBy.id) {
            AppLogger.bills.debug('Position: "${pos['desc']}" → DU selbst (${posAmount}€) [KEINE SCHULD]');
          } else {
            AppLogger.bills.debug('Position: "${pos['desc']}" → ${assignedPerson.name} schuldet DIR (${posAmount}€) ✅');
          }
        }
      }
      
      // Falls keine Positionen gefunden: Erstelle Dummy-Item
      if (items.isEmpty) {
        items.add(BillItem(
          id: 'bill_$billId',
          name: rawBill['title'] ?? 'Rechnung',
          amount: realTotal,
          sharedWith: [paidBy], // Fallback: Du schuldest dir selbst (keine Schuld)
        ));
        AppLogger.bills.debug('📍 Fallback-Item: Keine Positionen gefunden, keine Schulden');
      }
      
      final sharedBill = SharedBill(
        id: 'sqlite_$billId',
        title: rawBill['title'] ?? 'Rechnung',
        description: 'Aus SQLite geladen',
        totalAmount: realTotal,
        date: DateTime.tryParse(rawBill['date'] ?? '') ?? DateTime.now(),
        eventName: rawBill['title'],
        paidBy: paidBy,
        items: items,
        status: BillStatus.shared,
        createdAt: DateTime.tryParse(rawBill['date'] ?? '') ?? DateTime.now(),
      );
      
      AppLogger.bills.info('🎯 SharedBill erstellt: "${sharedBill.title}" (${sharedBill.totalAmount}€, ${sharedBill.items.length} items)');
      
      // WICHTIG: Test der Schuldenberechnung direkt hier
      final debts = sharedBill.getDebts();
      AppLogger.bills.debug('💰 SCHULDEN-TEST für "${sharedBill.title}":');
      AppLogger.bills.debug('   - Bezahlt von: ${sharedBill.paidBy.name}');
      AppLogger.bills.debug('   - Schulden: ${debts.length}');
      for (final entry in debts.entries) {
        AppLogger.bills.debug('   - ${entry.key.name} schuldet ${entry.value.toStringAsFixed(2)}€');
      }
      
      return sharedBill;
      
    } catch (e) {
      AppLogger.bills.error('⚠️ Fehler beim Laden der echten Summe für Bill $billId: $e');
      // Fallback: Verwende 0.00€
      final paidBy = await getCurrentUser();
      return SharedBill(
        id: 'sqlite_$billId',
        title: rawBill['title'] ?? 'Rechnung',
        description: 'Aus SQLite geladen (Fehler)',
        totalAmount: 0.0,
        date: DateTime.tryParse(rawBill['date'] ?? '') ?? DateTime.now(),
        eventName: rawBill['title'],
        paidBy: paidBy,
        items: [],
        status: BillStatus.shared,
        createdAt: DateTime.tryParse(rawBill['date'] ?? '') ?? DateTime.now(),
      );
    }
  }

  /// Findet Person anhand User-ID
  Future<Person?> _findPersonByUserId(int userId) async {
    final currentUser = await getCurrentUser();
    if (currentUser.id == userId.toString()) {
      AppLogger.users.debug('👤 User ID $userId → Current User: ${currentUser.name}');
      return currentUser;
    }
    
    final friends = await getAllFriends();
    for (final friend in friends) {
      if (friend.id == userId.toString()) {
        AppLogger.users.debug('👤 User ID $userId → Friend: ${friend.name}');
        return friend;
      }
    }
    
    AppLogger.users.error('⚠️ User ID $userId nicht gefunden');
    return null;
  }

  /// Fügt einen neuen Freund hinzu
  Future<Person> addFriend(Person friend) async {
    return await _userService.addFriend(
      name: friend.name,
      email: friend.email,
      phone: friend.phone,
    );
  }

  /// Erstellt eine neue geteilte Rechnung
  Future<SharedBill> createSharedBill({
    required String title,
    required double totalAmount,
    required Person paidBy,
    required List<BillItem> items,
    String? description,
    String? eventName,
    String? photoUrl,
  }) async {
    final bill = SharedBill(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      totalAmount: totalAmount,
      date: DateTime.now(),
      eventName: eventName,
      photoUrl: photoUrl,
      paidBy: paidBy,
      items: items,
      status: BillStatus.draft,
      createdAt: DateTime.now(),
    );
    
    final appMode = AppModeService();
    if (appMode.isRealMode) {
      AppLogger.bills.info('🏠 BillSharingService.createSharedBill: Real-Mode - Persistent speichern');
      // TODO: [IMPLEMENTATION] Hier später echte Repository-Integration
      // Für jetzt: Auch im Real-Mode in-memory speichern aber markieren
      AppLogger.bills.success('📝 Rechnung "${bill.title}" im Real-Mode erstellt (ID: ${bill.id})');
    } else {
      AppLogger.bills.info('🎭 BillSharingService.createSharedBill: Demo-Mode - In-Memory');
    }
    
    _sharedBills.add(bill);
    return bill;
  }

  /// Teilt eine Rechnung (ändert Status zu shared)
  void shareBill(String billId) {
    final index = _sharedBills.indexWhere((bill) => bill.id == billId);
    if (index != -1) {
      _sharedBills[index] = _sharedBills[index].copyWith(status: BillStatus.shared);
    }
  }

  /// Markiert eine Rechnung als vollständig beglichen
  void settleBill(String billId) {
    final index = _sharedBills.indexWhere((bill) => bill.id == billId);
    if (index != -1) {
      _sharedBills[index] = _sharedBills[index].copyWith(status: BillStatus.settled);
    }
  }

  /// Berechnet alle Schulden zwischen Personen
  /// 
  /// WICHTIG: Verwendet jetzt alle Rechnungen (In-Memory + SQLite)
  Future<List<Debt>> calculateAllDebts() async {
    AppLogger.bills.info('💰 SCHULDEN-BERECHNUNG gestartet...');
    
    // Alle Rechnungen laden (inkl. SQLite)
    final allBills = await getAllSharedBills();
    AppLogger.bills.debug('💰 Berechnungsgrundlage: ${allBills.length} Rechnungen');
    
    final Map<String, Map<String, double>> debtMatrix = {};
    
    for (final bill in allBills) {
      if (bill.status == BillStatus.settled) {
        AppLogger.bills.debug('💰 Überspringe beglichene Rechnung: ${bill.title}');
        continue;
      }
      
      AppLogger.bills.debug('💰 Verarbeite Rechnung: "${bill.title}"');
      final debts = bill.getDebts();
      AppLogger.bills.debug('💰   -> ${debts.length} Schulden gefunden');
      
      for (final entry in debts.entries) {
        final debtorId = entry.key.id;
        final creditorId = bill.paidBy.id;
        final amount = entry.value;
        
        AppLogger.bills.debug('💰   -> ${entry.key.name} schuldet ${bill.paidBy.name}: ${amount.toStringAsFixed(2)}€');
        
        debtMatrix[debtorId] ??= {};
        debtMatrix[debtorId]![creditorId] = (debtMatrix[debtorId]![creditorId] ?? 0.0) + amount;
      }
    }
    
    // Konvertiere zu Debt-Objekten
    final List<Debt> allDebts = [];
    for (final debtorId in debtMatrix.keys) {
      for (final creditorId in debtMatrix[debtorId]!.keys) {
        final amount = debtMatrix[debtorId]![creditorId]!;
        if (amount > 0.01) { // Ignoriere sehr kleine Beträge
          final debtor = await _findPersonById(debtorId);
          final creditor = await _findPersonById(creditorId);
          
          if (debtor != null && creditor != null) {
            allDebts.add(Debt(
              debtor: debtor,
              creditor: creditor,
              amount: amount,
              fromBills: _getBillsInvolvingPersons(debtor, creditor),
            ));
          }
        }
      }
    }
    
    return allDebts;
  }

  Future<Person?> _findPersonById(String id) async {
    final currentUser = await _userService.getCurrentUser();
    if (id == currentUser.id) return currentUser;
    
    final friends = await _userService.getAllFriends();
    try {
      return friends.firstWhere((friend) => friend.id == id);
    } catch (e) {
      return null;
    }
  }

  List<SharedBill> _getBillsInvolvingPersons(Person person1, Person person2) {
    return _sharedBills.where((bill) {
      final involved = bill.involvedPeople;
      return involved.contains(person1) && involved.contains(person2);
    }).toList();
  }

  /// Sucht Freunde nach Namen
  Future<List<Person>> searchFriends(String query) async {
    return await _userService.searchFriends(query);
  }

  /// Gibt Rechnungen für einen bestimmten Event zurück
  List<SharedBill> getBillsForEvent(String eventName) {
    return _sharedBills.where((bill) =>
      bill.eventName?.toLowerCase().contains(eventName.toLowerCase()) ?? false
    ).toList();
  }
}