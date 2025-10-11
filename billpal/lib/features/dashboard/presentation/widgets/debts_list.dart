import 'package:billpal/core/utils/currency.dart';
import 'package:billpal/models/financial_data.dart';
import 'package:billpal/models/invoice.dart';
import 'package:flutter/material.dart';

class DebtsList extends StatelessWidget {
  final BillSharingSummary summary;
  const DebtsList({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    // Wenn keine Schulden offen sind
    if (summary.myDebts.isEmpty && summary.myCredits.isEmpty) {
      return _balancedCard();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktuelle Schulden',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Wenn ich schulden habe/Meine Schulden
          if (summary.myDebts.isNotEmpty) ...[
            const Text(
              'Du schuldest:',
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
            ),
            const SizedBox(height: 8),
            ...summary.myDebts.map((d) => _DebtRow(debt: d, isCredit: false)),
            const SizedBox(height: 16),
          ],

          // Wenn mir was geschuldet wird
          if (summary.myCredits.isNotEmpty) ...[
            const Text(
              'Dir wird geschuldet:',
              style: TextStyle(
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

  Widget _balancedCard() => Container(
    padding: const EdgeInsets.all(24),
    decoration: _box(),
    child: Column(
      children: [
        Icon(
          Icons.account_balance_wallet,
          size: 48,
          color: Colors.green.shade400,
        ),
        const SizedBox(height: 12),
        const Text(
          'Alles ausgeglichen! 🎉',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Du hast keine offenen Schulden',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    ),
  );

  BoxDecoration _box() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
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
