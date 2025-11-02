import 'package:billpal/core/utils/currency.dart';
import 'package:billpal/shared/domain/entities/person.dart';

/// Datenmodell für eine geteilte Rechnung
class SharedBill {
  final String id;
  final String title;
  final String? description;
  final double totalAmount;
  final DateTime date;
  final String? eventName; // z.B. "Achtbar 19.11.2025"
  final String? photoUrl;
  final String? qrCode;
  final Person paidBy; // Wer hat bezahlt
  final List<BillItem> items;
  final BillStatus status;
  final DateTime createdAt;

  const SharedBill({
    required this.id,
    required this.title,
    this.description,
    required this.totalAmount,
    required this.date,
    this.eventName,
    this.photoUrl,
    this.qrCode,
    required this.paidBy,
    required this.items,
    required this.status,
    required this.createdAt,
  });

  /// Berechnet den Gesamtbetrag aus allen Items
  double get calculatedTotal => items.fold(0.0, (sum, item) => sum + item.amount);

  /// Gibt alle beteiligten Personen zurück
  Set<Person> get involvedPeople {
    final Set<Person> people = {paidBy};
    for (final item in items) {
      people.addAll(item.sharedWith);
    }
    return people;
  }

  /// Berechnet was jede Person schuldet
  Map<Person, double> getDebts() {
    final Map<Person, double> debts = {};
    
    for (final item in items) {
      final amountPerPerson = item.amount / item.sharedWith.length;
      for (final person in item.sharedWith) {
        if (person != paidBy) {
          debts[person] = (debts[person] ?? 0.0) + amountPerPerson;
        }
      }
    }
    
    return debts;
  }

  SharedBill copyWith({
    String? id,
    String? title,
    String? description,
    double? totalAmount,
    DateTime? date,
    String? eventName,
    String? photoUrl,
    String? qrCode,
    Person? paidBy,
    List<BillItem>? items,
    BillStatus? status,
    DateTime? createdAt,
  }) {
    return SharedBill(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      totalAmount: totalAmount ?? this.totalAmount,
      date: date ?? this.date,
      eventName: eventName ?? this.eventName,
      photoUrl: photoUrl ?? this.photoUrl,
      qrCode: qrCode ?? this.qrCode,
      paidBy: paidBy ?? this.paidBy,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'SharedBill(id: $id, title: $title, total: $totalAmount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SharedBill && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Ein einzelner Posten auf der Rechnung
class BillItem {
  final String id;
  final String name;
  final double amount;
  final List<Person> sharedWith; // Mit wem wird dieser Posten geteilt
  final String? category;

  const BillItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.sharedWith,
    this.category,
  });

  /// Betrag pro Person für diesen Posten
  double get amountPerPerson => amount / sharedWith.length;

  BillItem copyWith({
    String? id,
    String? name,
    double? amount,
    List<Person>? sharedWith,
    String? category,
  }) {
    return BillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      sharedWith: sharedWith ?? this.sharedWith,
      category: category ?? this.category,
    );
  }

  @override
  String toString() => 'BillItem(name: $name, amount: $amount, sharedWith: ${sharedWith.length} people)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Status einer geteilten Rechnung
enum BillStatus {
  draft,      // Entwurf
  shared,     // Geteilt/versendet
  settled,    // Vollständig beglichen
  cancelled,  // Storniert
}

/// Schuld zwischen zwei Personen
class Debt {
  final Person debtor;    // Schuldner
  final Person creditor;  // Gläubiger
  final double amount;
  final List<SharedBill> fromBills; // Aus welchen Rechnungen sich die Schuld zusammensetzt

  const Debt({
    required this.debtor,
    required this.creditor,
    required this.amount,
    required this.fromBills,
  });

  @override
  String toString() => 'Debt(${debtor.name} owes ${creditor.name} ${euro(amount)})';
}

/// Erweiterungen für bessere Lesbarkeit
extension BillStatusExtension on BillStatus {
  String get displayName {
    switch (this) {
      case BillStatus.draft:
        return 'Entwurf';
      case BillStatus.shared:
        return 'Geteilt';
      case BillStatus.settled:
        return 'Beglichen';
      case BillStatus.cancelled:
        return 'Storniert';
    }
  }

  String get description {
    switch (this) {
      case BillStatus.draft:
        return 'Rechnung wird noch bearbeitet';
      case BillStatus.shared:
        return 'Rechnung wurde an Freunde gesendet';
      case BillStatus.settled:
        return 'Alle Schulden sind beglichen';
      case BillStatus.cancelled:
        return 'Rechnung wurde storniert';
    }
  }
}