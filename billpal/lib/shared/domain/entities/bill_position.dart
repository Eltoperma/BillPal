import 'package:billpal/shared/domain/entities.dart';

/// Datenmodell für eine Position mit Settlement-Status
class BillPosition {
  final int id;
  final String description;
  final double amount;
  final Person assignedTo;
  bool isSettled;

  BillPosition({
    required this.id,
    required this.description,
    required this.amount,
    required this.assignedTo,
    this.isSettled = false,
  });
}