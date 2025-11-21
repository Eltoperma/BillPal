import 'package:billpal/core/utils/currency.dart';
import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Zeigt die letzten Rechnungen im Dashboard an
class RecentBillsList extends StatelessWidget {
  final BillSharingSummary summary;
  const RecentBillsList({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (summary.recentBills.isEmpty) {
      return _emptyCard(context);
    }

    // Zeige nur die letzten 5 Rechnungen
    final recentBills = summary.recentBills.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentBills,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (summary.recentBills.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/history');
                  },
                  child: Text(l10n.showAll),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...recentBills.map((bill) => _BillRow(bill: bill)),
        ],
      ),
    );
  }

  Widget _emptyCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _box(context),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noBillsYet,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.createFirstBill,
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

class _BillRow extends StatelessWidget {
  final SharedBill bill;
  const _BillRow({required this.bill});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(bill.status);
    final statusIcon = _getStatusIcon(bill.status);
    
    return GestureDetector(
      onTap: () {
        // Navigiere zur Bill Detail Page
        Navigator.pushNamed(
          context, 
          '/bill-detail',
          arguments: bill,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Bill Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy').format(bill.date),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const Text(' • '),
                      Text(
                        '${bill.items.length} Position${bill.items.length == 1 ? '' : 'en'}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  euro(bill.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _getStatusText(bill.status, context),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(BillStatus status) {
    switch (status) {
      case BillStatus.draft:
        return Colors.grey;
      case BillStatus.shared:
        return Colors.orange;
      case BillStatus.settled:
        return Colors.green;
      case BillStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(BillStatus status) {
    switch (status) {
      case BillStatus.draft:
        return Icons.edit;
      case BillStatus.shared:
        return Icons.share;
      case BillStatus.settled:
        return Icons.check_circle;
      case BillStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(BillStatus status, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case BillStatus.draft:
        return l10n.statusDraft;
      case BillStatus.shared:
        return l10n.statusShared;
      case BillStatus.settled:
        return l10n.statusSettled;
      case BillStatus.cancelled:
        return l10n.statusCancelled;
    }
  }
}