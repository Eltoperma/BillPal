import 'package:billpal/features/dashboard/presentation/widgets/pie_chart.dart';
import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ExpenseChartSection extends StatelessWidget {
  final List<PieSlice> expenseSlices;
  const ExpenseChartSection({super.key, required this.expenseSlices});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          // Überschrift pie chart
          Text(
            l10n.sharedExpenses,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          // Abstand
          const SizedBox(height: 16),

          // pie chart
          PieChart(
            slices: _localizeSlices(expenseSlices, l10n),
            size: 220,
            showLegend: true,
            showLabels: false,
          ),
        ],
      ),
    );
  }
  
  /// Lokalisiert die PieSlices für die Anzeige
  List<PieSlice> _localizeSlices(List<PieSlice> slices, AppLocalizations l10n) {
    return slices.map((slice) {
      final localizedLabel = _getLocalizedCategoryName(slice.label, l10n);
      
      return PieSlice(
        value: slice.value,
        color: slice.color,
        label: localizedLabel,
        amount: slice.amount,
        billCount: slice.billCount,
      );
    }).toList();
  }
  
  /// Gibt den lokalisierten Kategorienamen zurück
  String _getLocalizedCategoryName(String categoryId, AppLocalizations l10n) {
    switch (categoryId) {
      case 'restaurant_food':
        return l10n.categoryRestaurantFood;
      case 'entertainment':
        return l10n.categoryEntertainment;
      case 'transport':
        return l10n.categoryTransport;
      case 'shopping':
        return l10n.categoryShopping;
      case 'housing':
        return l10n.categoryHousing;
      case 'other':
      default:
        return l10n.categoryOtherGeneral;
    }
  }
}
