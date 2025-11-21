import 'package:billpal/core/utils/currency.dart';
import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final BillSharingSummary summary;
  const DashboardHeader({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final positive = summary.netBalance >= 0;
    final color = positive ? Colors.green : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.appTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),  
        const SizedBox(height: 4),
        Text(l10n.appSubtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
            )),
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
                  ? l10n.youWillReceive(euro(summary.netBalance))
                  : l10n.youOwe(euro(-summary.netBalance)),
              style: TextStyle(color: color.shade700, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ]),
        ),
      ],
    );
  }
}
