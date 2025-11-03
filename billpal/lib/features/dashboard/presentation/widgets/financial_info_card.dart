import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Wiederverwendbare Info-Karte für Bill-Sharing Übersicht
class BillSharingCard extends StatelessWidget {
  final SummaryCard card;

  const BillSharingCard({
    required this.card,
    super.key,
  });

  String _getLocalizedTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Bestimme Titel basierend auf Icon oder Original-Titel
    if (card.title.contains('Du schuldest') || card.icon == Icons.arrow_upward) {
      return l10n.youOweColon.replaceAll(':', '');
    } else if (card.title.contains('Dir wird geschuldet') || card.icon == Icons.arrow_downward) {
      return l10n.owedToYouColon.replaceAll(':', '');
    }
    return card.title;
  }

  String _getLocalizedSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final count = card.count;
    // Erstelle lokalisierten Untertitel: "X Person" / "X Personen"
    return count == 1 
        ? '$count ${l10n.friendCount(1).replaceAll('1 ', '')}'
        : '$count ${l10n.friendCountPlural(count).replaceAll('$count ', '')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToHistory(context),
      child: Container(
      constraints: const BoxConstraints(minHeight: 100),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
                      _getLocalizedTitle(context),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
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
                      _getLocalizedSubtitle(context),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
    ),
    );
  }

  void _navigateToHistory(BuildContext context) {
    String? filterBy;
    
    // Bestimme Filter basierend auf Kartentitel oder Icon
    if (card.title.contains('Du schuldest') || card.icon == Icons.arrow_upward) {
      filterBy = 'i_owe';
    } else if (card.title.contains('Dir wird geschuldet') || card.icon == Icons.arrow_downward) {
      filterBy = 'owed_to_me';
    }
    
    Navigator.pushNamed(
      context,
      '/history',
      arguments: {
        'filterBy': filterBy,
      },
    );
  }
}
