import 'package:billpal/core/utils/currency.dart';
import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DebtsList extends StatelessWidget {
  final BillSharingSummary summary;
  const DebtsList({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Wenn keine Schulden offen sind
    if (summary.myDebts.isEmpty && summary.myCredits.isEmpty) {
      return _balancedCard(context);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.currentDebts,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Wenn ich schulden habe/Meine Schulden
          if (summary.myDebts.isNotEmpty) ...[
            Text(
              l10n.youOweColon,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
            ),
            const SizedBox(height: 8),
            ...summary.myDebts.map((d) => _DebtRow(debt: d, isCredit: false)),
            const SizedBox(height: 16),
          ],

          // Wenn mir was geschuldet wird
          if (summary.myCredits.isNotEmpty) ...[
            Text(
              l10n.owedToYouColon,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            ...summary.myCredits.map((d) => _DebtRow(debt: d, isCredit: true)),
          ],
        ],
      ),
    );
  }

  Widget _balancedCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _box(context),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 48,
            color: Colors.green.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.allBalanced,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.noOpenDebts,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  BoxDecoration _box(BuildContext context) => BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

class _DebtRow extends StatelessWidget {
  final Debt debt;
  final bool isCredit;
  const _DebtRow({required this.debt, required this.isCredit});

  @override
  Widget build(BuildContext context) {
    final person = isCredit ? debt.debtor : debt.creditor;
    final color = isCredit ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.shade100,
            child: Text(
              person.name[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              person.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            euro(debt.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
