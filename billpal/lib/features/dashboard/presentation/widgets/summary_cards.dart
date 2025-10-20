import 'package:billpal/models/financial_data.dart';
import 'package:billpal/features/dashboard/presentation/widgets/financial_info_card.dart';
import 'package:flutter/material.dart';

class SummaryCards extends StatelessWidget {
  final List<SummaryCard> cards;
  const SummaryCards({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    // Wenn weniger als 2 Karten vorhanden sind, nichts anzeigen
    if (cards.length < 2) return const SizedBox.shrink();

    return Row(
      children: [
        // Du schuldest
        Expanded(child: BillSharingCard(card: cards[0])),

        // Lücke zwischen den beiden Karten
        const SizedBox(width: 16),

        // Dir wird geschuldet
        Expanded(child: BillSharingCard(card: cards[1])),
      ],
    );
  }
}
