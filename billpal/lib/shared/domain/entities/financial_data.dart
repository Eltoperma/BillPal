import 'package:billpal/core/utils/currency.dart';
import 'package:billpal/shared/domain/entities/person.dart';
import 'package:billpal/shared/domain/entities/bill.dart';
import 'package:flutter/material.dart';

/// Zusammenfassung der geteilten Rechnungen für das Dashboard
class BillSharingSummary {
  final double totalOwed;          // Was ich anderen schulde
  final double totalOwedToMe;      // Was andere mir schulden
  final List<Debt> myDebts;        // Meine Schulden
  final List<Debt> myCredits;      // Was mir geschuldet wird
  final List<SharedBill> recentBills;
  final DateTime lastUpdated;

  const BillSharingSummary({
    required this.totalOwed,
    required this.totalOwedToMe,
    required this.myDebts,
    required this.myCredits,
    required this.recentBills,
    required this.lastUpdated,
  });

  /// Netto-Saldo (was mir geschuldet wird minus was ich schulde)
  double get netBalance => totalOwedToMe - totalOwed;

  /// Anzahl offener Rechnungen
  int get openBillsCount => recentBills.where((bill) => bill.status != BillStatus.settled).length;

  /// Anzahl Personen, denen ich Geld schulde
  int get peopleIOweMoney => myDebts.length;

  /// Anzahl Personen, die mir Geld schulden
  int get peopleWhoOweMeMoney => myCredits.length;

  BillSharingSummary copyWith({
    double? totalOwed,
    double? totalOwedToMe,
    List<Debt>? myDebts,
    List<Debt>? myCredits,
    List<SharedBill>? recentBills,
    DateTime? lastUpdated,
  }) {
    return BillSharingSummary(
      totalOwed: totalOwed ?? this.totalOwed,
      totalOwedToMe: totalOwedToMe ?? this.totalOwedToMe,
      myDebts: myDebts ?? this.myDebts,
      myCredits: myCredits ?? this.myCredits,
      recentBills: recentBills ?? this.recentBills,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Daten für die Übersichtskarten
class SummaryCard {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final String subtitle;
  final int count; // Anzahl Personen oder Rechnungen

  const SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.subtitle,
    required this.count,
  });

  /// Formatierte Anzeige des Betrags
  String get formattedAmount => euro(amount);

  /// Formatierte Anzeige der Anzahl
  String get formattedCount => count == 1 ? '$count Person' : '$count Personen';
}

/// Event-Vorschlag basierend auf Datum und Wochentag
class EventSuggestion {
  final String eventName;
  final DateTime suggestedDate;
  final String description;
  final IconData icon;

  const EventSuggestion({
    required this.eventName,
    required this.suggestedDate,
    required this.description,
    required this.icon,
  });

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
      'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'
    ];
    final weekdays = [
      'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'
    ];
    
    final day = suggestedDate.day.toString().padLeft(2, '0');
    final month = months[suggestedDate.month - 1];
    final weekday = weekdays[suggestedDate.weekday - 1];
    
    return '$weekday, $day. $month ${suggestedDate.year}';
  }
}

/// OCR-Ergebnis für ausgelesene Rechnungen
class OCRResult {
  final String? merchantName;
  final double? totalAmount;
  final DateTime? date;
  final List<OCRItem> items;
  final double confidence; // Vertrauen in die Erkennung (0.0-1.0)

  const OCRResult({
    this.merchantName,
    this.totalAmount,
    this.date,
    required this.items,
    required this.confidence,
  });

  bool get isReliable => confidence > 0.8;
}

/// Einzelner Posten aus OCR-Erkennung
class OCRItem {
  final String name;
  final double? amount;
  final int? quantity;

  const OCRItem({
    required this.name,
    this.amount,
    this.quantity,
  });
}

/// Daten für Kreisdiagramm der geteilten Ausgaben
class ExpenseCategory {
  final String category;
  final double amount;
  final Color color;
  final int billCount;
  final List<String> friendsInvolved;

  const ExpenseCategory({
    required this.category,
    required this.amount,
    required this.color,
    required this.billCount,
    required this.friendsInvolved,
  });

  /// Prozentualer Anteil an Gesamtausgaben
  double getPercentage(double total) {
    if (total == 0) return 0;
    return amount / total;
  }
}

/// Segment für Kreisdiagramm
class PieSlice {
  final double value; // Anteil (0..1)
  final Color color;
  final String label;
  final double amount;
  final int billCount;

  const PieSlice({
    required this.value,
    required this.color,
    required this.label,
    required this.amount,
    required this.billCount,
  });

  String get description => '$billCount Bill${billCount == 1 ? '' : 's'}'; // Placeholder - wird in UI lokalisiert
}

/// Freundschafts-Statistik
class FriendStats {
  final Person friend;
  final double totalSharedAmount;
  final int sharedBillsCount;
  final double currentDebt; // Positiv = Freund schuldet mir, Negativ = Ich schulde Freund
  final DateTime lastActivity;

  const FriendStats({
    required this.friend,
    required this.totalSharedAmount,
    required this.sharedBillsCount,
    required this.currentDebt,
    required this.lastActivity,
  });

}