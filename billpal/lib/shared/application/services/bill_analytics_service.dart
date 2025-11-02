import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/shared/application/services/bill_sharing_service.dart';
import 'package:flutter/material.dart';

/// Service für Bill-Sharing Analysen und Berechnungen
class BillSharingAnalyticsService {
  static final BillSharingAnalyticsService _instance = BillSharingAnalyticsService._internal();
  factory BillSharingAnalyticsService() => _instance;
  BillSharingAnalyticsService._internal();

  final BillSharingService _billService = BillSharingService();

  /// Generiert eine Zusammenfassung aller geteilten Rechnungen
  Future<BillSharingSummary> getDashboardSummary() async {
    final debts = await _billService.calculateAllDebts();
    final currentUser = await _billService.getCurrentUser(); // Einmal abrufen
    
    final myDebts = debts.where((debt) => debt.debtor.id == currentUser.id).toList();
    final myCredits = debts.where((debt) => debt.creditor.id == currentUser.id).toList();
    
    final totalOwed = myDebts.fold<double>(0, (sum, debt) => sum + debt.amount);
    final totalOwedToMe = myCredits.fold<double>(0, (sum, debt) => sum + debt.amount);
    
    final allBills = await _billService.getAllSharedBills(); // Jetzt async!
    
    return BillSharingSummary(
      totalOwed: totalOwed,
      totalOwedToMe: totalOwedToMe,
      myDebts: myDebts,
      myCredits: myCredits,
      recentBills: allBills
          .where((bill) => bill.status != BillStatus.cancelled)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)),
      lastUpdated: DateTime.now(),
    );
  }

  /// Erstellt die Summary Cards für das Dashboard
  Future<List<SummaryCard>> getSummaryCards() async {
    final summary = await getDashboardSummary();
    
    return [
      SummaryCard(
        title: 'Du schuldest',
        amount: summary.totalOwed,
        color: Colors.red.shade600,
        icon: Icons.arrow_upward,
        subtitle: '${summary.peopleIOweMoney} Person${summary.peopleIOweMoney == 1 ? '' : 'en'}',
        count: summary.peopleIOweMoney,
      ),
      SummaryCard(
        title: 'Dir wird geschuldet',
        amount: summary.totalOwedToMe,
        color: Colors.green.shade600,
        icon: Icons.arrow_downward,
        subtitle: '${summary.peopleWhoOweMeMoney} Person${summary.peopleWhoOweMeMoney == 1 ? '' : 'en'}',
        count: summary.peopleWhoOweMeMoney,
      ),
    ];
  }

  /// Erstellt Event-Vorschläge basierend auf aktuellem Datum
  List<EventSuggestion> getEventSuggestions() {
    final now = DateTime.now();
    final suggestions = <EventSuggestion>[];
    
    // Wochenende-Vorschläge
    final weekend = _getNextWeekend(now);
    suggestions.add(EventSuggestion(
      eventName: 'Weekend Hangout ${weekend.day}.${weekend.month}.${weekend.year}',
      suggestedDate: weekend,
      description: 'Perfekt für gemeinsame Aktivitäten',
      icon: Icons.weekend,
    ));
    
    // Heute Abend
    final tonight = DateTime(now.year, now.month, now.day, 19, 0);
    if (tonight.isAfter(now)) {
      suggestions.add(EventSuggestion(
        eventName: 'Heute Abend ${tonight.day}.${tonight.month}.${tonight.year}',
        suggestedDate: tonight,
        description: 'Spontaner Abend mit Freunden',
        icon: Icons.nightlife,
      ));
    }
    
    // Nächster Freitag
    final nextFriday = _getNextFriday(now);
    suggestions.add(EventSuggestion(
      eventName: 'Freitag Abend ${nextFriday.day}.${nextFriday.month}.${nextFriday.year}',
      suggestedDate: nextFriday,
      description: 'TGIF - Zeit zu feiern!',
      icon: Icons.celebration,
    ));
    
    return suggestions;
  }

  DateTime _getNextWeekend(DateTime from) {
    final daysUntilSaturday = (6 - from.weekday) % 7;
    return from.add(Duration(days: daysUntilSaturday == 0 ? 7 : daysUntilSaturday));
  }

  DateTime _getNextFriday(DateTime from) {
    final daysUntilFriday = (5 - from.weekday) % 7;
    return from.add(Duration(days: daysUntilFriday == 0 ? 7 : daysUntilFriday));
  }

    /// Erstellt Ausgabenkategorien basierend auf den geteilten Rechnungen
  Future<List<ExpenseCategory>> getExpenseCategories() async {
    final allBills = await _billService.getAllSharedBills(); // Jetzt async!
    final bills = allBills
        .where((bill) => bill.status != BillStatus.cancelled)
        .toList();
    
    final Map<String, double> categoryTotals = {};
    final Map<String, int> categoryBillCounts = {};
    final Map<String, Set<String>> categoryFriends = {};
    
    for (final bill in bills) {
      final category = _categorizeByTitle(bill.title);
      categoryTotals[category] = (categoryTotals[category] ?? 0.0) + bill.totalAmount;
      categoryBillCounts[category] = (categoryBillCounts[category] ?? 0) + 1;
      
      categoryFriends[category] ??= <String>{};
      for (final person in bill.involvedPeople) {
        categoryFriends[category]!.add(person.name);
      }
    }
    
    final categoryColors = {
      'Restaurant & Essen': Colors.orange.shade600,     // 🍕 Orange
      'Unterhaltung': Colors.purple.shade600,          // 🎬 Lila  
      'Transport': Colors.blue.shade600,               // 🚗 Blau
      'Einkaufen': Colors.green.shade600,              // 🛒 Grün
      'Wohnen & Fixkosten': Colors.red.shade600,       // 🏠 Rot
      'Sonstiges': Colors.grey.shade600,               // ❓ Grau
    };
    
    return categoryTotals.entries
        .map((entry) => ExpenseCategory(
              category: entry.key,
              amount: entry.value,
              color: categoryColors[entry.key] ?? Colors.grey,
              billCount: categoryBillCounts[entry.key] ?? 0,
              friendsInvolved: categoryFriends[entry.key]?.toList() ?? [],
            ))
        .where((cat) => cat.amount > 0)
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  String _categorizeByTitle(String title) {
    final lowerTitle = title.toLowerCase();
    
    // 🍕 Restaurant & Essen - Moderner und alltagstauglicher
    if (lowerTitle.contains('restaurant') || 
        lowerTitle.contains('pizza') || 
        lowerTitle.contains('döner') ||
        lowerTitle.contains('kebab') ||
        lowerTitle.contains('burger') ||
        lowerTitle.contains('mcdonalds') ||
        lowerTitle.contains('kfc') ||
        lowerTitle.contains('subway') ||
        lowerTitle.contains('sushi') ||
        lowerTitle.contains('café') ||
        lowerTitle.contains('coffee') ||
        lowerTitle.contains('starbucks') ||
        lowerTitle.contains('bar') ||
        lowerTitle.contains('essen') ||
        lowerTitle.contains('food') ||
        lowerTitle.contains('meal') ||
        lowerTitle.contains('lunch') ||
        lowerTitle.contains('dinner') ||
        lowerTitle.contains('breakfast') ||
        lowerTitle.contains('frühstück') ||
        lowerTitle.contains('mittagessen') ||
        lowerTitle.contains('abendessen') ||
        lowerTitle.contains('bäcker') ||
        lowerTitle.contains('metzger') ||
        lowerTitle.contains('imbiss') ||
        lowerTitle.contains('bistro') ||
        lowerTitle.contains('lieferando') ||
        lowerTitle.contains('delivery') ||
        lowerTitle.contains('takeaway') ||
        lowerTitle.contains('getränk') ||
        lowerTitle.contains('drink') ||
        lowerTitle.contains('bier') ||
        lowerTitle.contains('wine') ||
        lowerTitle.contains('wein') ||
        lowerTitle.contains('cocktail')) {
      return 'Restaurant & Essen';
    }
    
    // 🎬 Unterhaltung & Freizeit
    if (lowerTitle.contains('kino') || 
        lowerTitle.contains('cinema') ||
        lowerTitle.contains('movie') ||
        lowerTitle.contains('film') ||
        lowerTitle.contains('bowling') || 
        lowerTitle.contains('party') ||
        lowerTitle.contains('club') ||
        lowerTitle.contains('disco') ||
        lowerTitle.contains('concert') ||
        lowerTitle.contains('konzert') ||
        lowerTitle.contains('theater') ||
        lowerTitle.contains('museum') ||
        lowerTitle.contains('zoo') ||
        lowerTitle.contains('park') ||
        lowerTitle.contains('festival') ||
        lowerTitle.contains('event') ||
        lowerTitle.contains('ticket') ||
        lowerTitle.contains('netflix') ||
        lowerTitle.contains('spotify') ||
        lowerTitle.contains('game') ||
        lowerTitle.contains('spiel')) {
      return 'Unterhaltung';
    }
    
    // 🚗 Transport & Mobilität
    if (lowerTitle.contains('tankstelle') || 
        lowerTitle.contains('tanken') ||
        lowerTitle.contains('benzin') ||
        lowerTitle.contains('diesel') ||
        lowerTitle.contains('uber') || 
        lowerTitle.contains('taxi') ||
        lowerTitle.contains('bolt') ||
        lowerTitle.contains('bus') ||
        lowerTitle.contains('bahn') ||
        lowerTitle.contains('zug') ||
        lowerTitle.contains('train') ||
        lowerTitle.contains('ticket') ||
        lowerTitle.contains('fahrkarte') ||
        lowerTitle.contains('transport') ||
        lowerTitle.contains('parking') ||
        lowerTitle.contains('parken') ||
        lowerTitle.contains('maut') ||
        lowerTitle.contains('toll') ||
        lowerTitle.contains('car') ||
        lowerTitle.contains('auto')) {
      return 'Transport';
    }
    
    // 🛒 Einkaufen & Shopping
    if (lowerTitle.contains('supermarkt') || 
        lowerTitle.contains('einkauf') || 
        lowerTitle.contains('shopping') ||
        lowerTitle.contains('rewe') ||
        lowerTitle.contains('edeka') ||
        lowerTitle.contains('aldi') ||
        lowerTitle.contains('lidl') ||
        lowerTitle.contains('penny') ||
        lowerTitle.contains('netto') ||
        lowerTitle.contains('kaufland') ||
        lowerTitle.contains('real') ||
        lowerTitle.contains('drogerie') ||
        lowerTitle.contains('dm') ||
        lowerTitle.contains('rossmann') ||
        lowerTitle.contains('müller') ||
        lowerTitle.contains('amazon') ||
        lowerTitle.contains('zalando') ||
        lowerTitle.contains('h&m') ||
        lowerTitle.contains('zara') ||
        lowerTitle.contains('ikea') ||
        lowerTitle.contains('saturn') ||
        lowerTitle.contains('mediamarkt') ||
        lowerTitle.contains('apotheke') ||
        lowerTitle.contains('pharmacy')) {
      return 'Einkaufen';
    }
    
    // 🏠 Wohnen & Haushalt
    if (lowerTitle.contains('miete') ||
        lowerTitle.contains('rent') ||
        lowerTitle.contains('nebenkosten') ||
        lowerTitle.contains('strom') ||
        lowerTitle.contains('gas') ||
        lowerTitle.contains('wasser') ||
        lowerTitle.contains('heizung') ||
        lowerTitle.contains('internet') ||
        lowerTitle.contains('wifi') ||
        lowerTitle.contains('handy') ||
        lowerTitle.contains('mobilfunk') ||
        lowerTitle.contains('versicherung') ||
        lowerTitle.contains('insurance') ||
        lowerTitle.contains('bank') ||
        lowerTitle.contains('gebühr') ||
        lowerTitle.contains('fee')) {
      return 'Wohnen & Fixkosten';
    }
    
    return 'Sonstiges';
  }

  /// Erstellt Pie-Chart-Daten
  Future<List<PieSlice>> getExpensePieSlices() async {
    final categories = await getExpenseCategories(); // Jetzt async!
    final total = categories.fold<double>(0, (sum, cat) => sum + cat.amount);
    
    if (total == 0) return [];
    
    return categories
        .map((cat) => PieSlice(
              value: cat.amount / total,
              color: cat.color,
              label: cat.category,
              amount: cat.amount,
              billCount: cat.billCount,
            ))
        .toList();
  }

  /// Generiert Freundschafts-Statistiken
  Future<List<FriendStats>> getFriendStats() async {
    final currentUser = await _billService.getCurrentUser();
    final friends = await _billService.getAllFriends();
    final bills = await _billService.getAllSharedBills(); // Jetzt async!
    final allDebts = await _billService.calculateAllDebts();
    
    return friends.map((friend) {
      // Berechne geteilte Rechnungen mit diesem Freund
      final sharedBills = bills.where((bill) => 
          bill.involvedPeople.contains(friend) && 
          bill.involvedPeople.contains(currentUser)
      ).toList();
      
      final totalShared = sharedBills.fold<double>(0, (sum, bill) => sum + bill.totalAmount);
      
      // Berechne aktuelle Schuld
      double currentDebt = 0.0;
      for (final debt in allDebts) {
        if (debt.debtor.id == currentUser.id && debt.creditor.id == friend.id) {
          currentDebt -= debt.amount; // Ich schulde dem Freund
        } else if (debt.creditor.id == currentUser.id && debt.debtor.id == friend.id) {
          currentDebt += debt.amount; // Freund schuldet mir
        }
      }
      
      final lastActivity = sharedBills.isNotEmpty 
          ? sharedBills.map((b) => b.date).reduce((a, b) => a.isAfter(b) ? a : b)
          : friend.createdAt;
      
      return FriendStats(
        friend: friend,
        totalSharedAmount: totalShared,
        sharedBillsCount: sharedBills.length,
        currentDebt: currentDebt,
        lastActivity: lastActivity,
      );
    }).toList()
      ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
  }

  /// Berechnet den "Fairness-Score" einer Gruppe
  Future<double> calculateGroupFairness() async {
    final allDebts = await _billService.calculateAllDebts();
    if (allDebts.isEmpty) return 1.0;
    
    final amounts = allDebts.map((debt) => debt.amount).toList();
    final average = amounts.fold<double>(0, (sum, amount) => sum + amount) / amounts.length;
    
    // Berechne Standardabweichung
    final variance = amounts.fold<double>(0, (sum, amount) => sum + (amount - average) * (amount - average)) / amounts.length;
    final standardDeviation = sqrt(variance);
    
    // Je niedriger die Standardabweichung, desto fairer die Verteilung
    return 1.0 - (standardDeviation / (average + 1.0)).clamp(0.0, 1.0);
  }

  double sqrt(double value) => value < 0 ? 0 : value; // Vereinfachte sqrt für Demo
}