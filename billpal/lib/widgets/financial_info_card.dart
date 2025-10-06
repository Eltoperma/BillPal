import 'package:flutter/material.dart';
import '../models/financial_data.dart';

/// Wiederverwendbare Info-Karte für Bill-Sharing Übersicht
class BillSharingCard extends StatelessWidget {
  final SummaryCard card;

  const BillSharingCard({
    required this.card,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header mit Icon und Titel
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  card.icon,
                  size: 16,
                  color: card.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card.title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      card.subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Betrag
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              card.formattedAmount,
              style: TextStyle(
                color: card.color,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Einfache Karte für Schnellübersicht
class SimpleBillCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const SimpleBillCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '${amount.toStringAsFixed(2)}€',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}