import 'package:flutter/material.dart';
import '../widgets/info_card.dart';
import '../widgets/pie_chart.dart';

/// Startseite wie im Mockup.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const pieData = <PieSlice>[
      PieSlice(value: 0.35, color: Color(0xFF26C281)), // grün
      PieSlice(value: 0.30, color: Color(0xFF5B8DEF)), // blau
      PieSlice(value: 0.20, color: Color(0xFFF6C443)), // gelb
      PieSlice(value: 0.15, color: Color(0xFFF06263)), // rot
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              Row(
                children: const [
                  Expanded(
                    child: InfoCard(
                      title: 'Verbindlichkeiten',
                      amount: 120.53,
                      amountColor: Color(0xFFE53935),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InfoCard(
                      title: 'Forderungen',
                      amount: 260,
                      amountColor: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: 240, height: 240,
                  child: const PieChart(slices: pieData),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '„Zu viel Monat am Ende des Geldes.“',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // später: zum „Neue Rechnung“-Flow navigieren
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Neue Rechnung hinzufügen')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
