import 'package:billpal/core/utils/currency.dart';
import 'package:billpal/models/financial_data.dart';
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final BillSharingSummary summary;
  const DashboardHeader({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final positive = summary.netBalance >= 0;
    final color = positive ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BillPal',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87
          ),
        ),  
        const SizedBox(height: 4),
        const Text('Geteilte Rechnungen mit Freunden',
            style: TextStyle(color: Colors.black54, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.shade200),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(positive ? Icons.trending_up : Icons.trending_down,
                size: 16, color: color.shade700),
            const SizedBox(width: 4),
            Text(
              positive
                  ? 'Du bekommst ${euro(summary.netBalance)}'
                  : 'Du schuldest ${euro(-summary.netBalance)}',
              style: TextStyle(color: color.shade700, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ]),
        ),
      ],
    );
  }
}
