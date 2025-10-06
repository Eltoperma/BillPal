import 'package:flutter/material.dart';
import '../../../../core/utils/currency.dart';

/// Wiederverwendbare Kennzahlen-Karte (Titel + Betrag in Farbe).
class InfoCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color amountColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            euro(amount),
            style: TextStyle(color: amountColor, fontWeight: FontWeight.w800, fontSize: 22),
          ),
        ],
      ),
    );
  }
}
