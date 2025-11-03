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
            slices: expenseSlices,
            size: 220,
            showLegend: true,
            showLabels: false,
          ),
        ],
      ),
    );
  }
}
