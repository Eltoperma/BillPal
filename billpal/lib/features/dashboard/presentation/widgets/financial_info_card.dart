import 'package:billpal/models/financial_data.dart';
import 'package:flutter/material.dart';

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

              // Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: card.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  card.icon,
                  size: 16,
                  color: card.color,
                ),
              ),

              const SizedBox(width: 10),

              // Text
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

                    // Personen Anzahl
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
