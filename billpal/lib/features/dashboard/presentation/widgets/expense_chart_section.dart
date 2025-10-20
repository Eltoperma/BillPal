import 'package:billpal/features/dashboard/presentation/widgets/pie_chart.dart';
import 'package:billpal/models/financial_data.dart';
import 'package:flutter/material.dart';

class ExpenseChartSection extends StatelessWidget {
  final List<PieSlice> expenseSlices;
  const ExpenseChartSection({super.key, required this.expenseSlices});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          // Überschrift pie chart
          Text(
            'Geteilte Ausgaben',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
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
