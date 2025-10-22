import 'dart:math';
import 'package:billpal/models/invoice.dart';
import 'package:billpal/core/app_mode/app_mode_service.dart';
import 'package:billpal/services/user_service.dart';

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

  /// Initialisiert den Service mit Demo-Daten
  /// 
  /// TODO: [CLEANUP] Diese Methode entfernen und durch echte Repository-Calls ersetzen
  Future<void> initializeDemoData() async {
    final appMode = AppModeService();
    
    // Nur in Demo-Mode oder wenn uninitialized Demo-Daten laden
    if (appMode.isDemoMode || appMode.isUninitialized) {
      print('🎭 BillSharingService: Demo-Daten werden geladen (Mode: ${appMode.currentMode.name})');
      _sharedBills.clear();
      
      // Erstelle Demo-Rechnungen (Freunde werden vom UserService verwaltet)
      await _createDemoSharedBills();
    } else {
      print('🏠 BillSharingService: Real-Mode aktiv, keine Demo-Daten geladen');
      // TODO: [CLEANUP] Hier später echte Repository-Calls implementieren
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
  List<SharedBill> getAllSharedBills() {
    return List.unmodifiable(_sharedBills);
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
  SharedBill createSharedBill({
    required String title,
    required double totalAmount,
    required Person paidBy,
    required List<BillItem> items,
    String? description,
    String? eventName,
    String? photoUrl,
  }) {
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
  /// TODO: [CLEANUP] Diese Methode muss async werden für echte Repository-Calls
  Future<List<Debt>> calculateAllDebts() async {
    final Map<String, Map<String, double>> debtMatrix = {};
    
    for (final bill in _sharedBills) {
      if (bill.status == BillStatus.settled) continue;
      
      final debts = bill.getDebts();
      for (final entry in debts.entries) {
        final debtorId = entry.key.id;
        final creditorId = bill.paidBy.id;
        final amount = entry.value;
        
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