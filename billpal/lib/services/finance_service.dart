import 'package:flutter/material.dart';
import '../models/financial_data.dart';
import '../models/invoice.dart';
import 'invoice_service.dart';

/// Service für Bill-Sharing Analysen und Berechnungen
class BillSharingAnalyticsService {
  static final BillSharingAnalyticsService _instance = BillSharingAnalyticsService._internal();
  factory BillSharingAnalyticsService() => _instance;
  BillSharingAnalyticsService._internal();

  final BillSharingService _billService = BillSharingService();

  /// Erstellt die Dashboard-Übersicht
  BillSharingSummary getDashboardSummary() {
    final currentUser = _billService.getCurrentUser();
    final allDebts = _billService.calculateAllDebts();
    
    // Was ich anderen schulde
    final myDebts = allDebts.where((debt) => debt.debtor.id == currentUser.id).toList();
    final totalOwed = myDebts.fold<double>(0, (sum, debt) => sum + debt.amount);
    
    // Was andere mir schulden
    final myCredits = allDebts.where((debt) => debt.creditor.id == currentUser.id).toList();
    final totalOwedToMe = myCredits.fold<double>(0, (sum, debt) => sum + debt.amount);
    
    return BillSharingSummary(
      totalOwed: totalOwed,
      totalOwedToMe: totalOwedToMe,
      myDebts: myDebts,
      myCredits: myCredits,
      recentBills: _billService.getAllSharedBills()
          .where((bill) => bill.status != BillStatus.cancelled)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date)),
      lastUpdated: DateTime.now(),
    );
  }

  /// Erstellt die Summary Cards für das Dashboard
  List<SummaryCard> getSummaryCards() {
    final summary = getDashboardSummary();
    
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

  /// Erstellt Ausgaben-Kategorien für das Kreisdiagramm
  List<ExpenseCategory> getExpenseCategories() {
    final bills = _billService.getAllSharedBills()
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
      'Restaurant & Essen': Colors.orange.shade600,
      'Unterhaltung': Colors.purple.shade600,
      'Transport': Colors.blue.shade600,
      'Einkaufen': Colors.green.shade600,
      'Sonstiges': Colors.grey.shade600,
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
    
    if (lowerTitle.contains('restaurant') || 
        lowerTitle.contains('pizza') || 
        lowerTitle.contains('café') ||
        lowerTitle.contains('bar') ||
        lowerTitle.contains('essen') ||
        lowerTitle.contains('tante emma')) {
      return 'Restaurant & Essen';
    }
    
    if (lowerTitle.contains('bowling') || 
        lowerTitle.contains('kino') || 
        lowerTitle.contains('bar') ||
        lowerTitle.contains('party')) {
      return 'Unterhaltung';
    }
    
    if (lowerTitle.contains('tankstelle') || 
        lowerTitle.contains('uber') || 
        lowerTitle.contains('taxi') ||
        lowerTitle.contains('bus') ||
        lowerTitle.contains('bahn')) {
      return 'Transport';
    }
    
    if (lowerTitle.contains('supermarkt') || 
        lowerTitle.contains('einkauf') || 
        lowerTitle.contains('drogerie')) {
      return 'Einkaufen';
    }
    
    return 'Sonstiges';
  }

  /// Erstellt Pie-Chart-Daten
  List<ExpensePieSlice> getExpensePieSlices() {
    final categories = getExpenseCategories();
    final total = categories.fold<double>(0, (sum, cat) => sum + cat.amount);
    
    if (total == 0) return [];
    
    return categories
        .map((cat) => ExpensePieSlice(
              value: cat.amount / total,
              color: cat.color,
              label: cat.category,
              amount: cat.amount,
              billCount: cat.billCount,
            ))
        .toList();
  }

  /// Gibt Freundschafts-Statistiken zurück
  List<FriendStats> getFriendStats() {
    final currentUser = _billService.getCurrentUser();
    final friends = _billService.getAllFriends();
    final bills = _billService.getAllSharedBills();
    final allDebts = _billService.calculateAllDebts();
    
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
  double calculateGroupFairness() {
    final allDebts = _billService.calculateAllDebts();
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