import 'package:billpal/features/dashboard/application/dashboard_controller.dart';
import 'package:billpal/features/dashboard/presentation/widgets/add_bill_fab.dart';
import 'package:billpal/features/dashboard/presentation/widgets/debts_list.dart';
import 'package:billpal/features/dashboard/presentation/widgets/event_suggestions.dart';
import 'package:billpal/features/dashboard/presentation/widgets/expense_chart_section.dart';
import 'package:billpal/features/dashboard/presentation/widgets/header.dart';
import 'package:billpal/features/dashboard/presentation/widgets/summary_cards.dart';
import 'package:billpal/services/finance_service.dart';
import 'package:billpal/services/invoice_service.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController _controller;
  DashboardState _state = const DashboardState(isLoading: true);

  @override
  void initState() {
    super.initState();
    _controller = DashboardController(
      analytics: BillSharingAnalyticsService(),
      bills: BillSharingService(),
    );
    _reload();
  }

  // Reload der Daten
  Future<void> _reload() async {
    setState(() => _state = _state.copyWith(isLoading: true));
    // Lädt neue Demo Daten
    final s = await _controller.load();
    setState(() => _state = s);
  }

  @override
  Widget build(BuildContext context) {
    if (_state.isLoading || _state.summary == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F6F8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final summary = _state.summary!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                DashboardHeader(summary: summary),

                const SizedBox(height: 24),

                // Karten: Schulden-Übersicht
                SummaryCards(cards: _state.summaryCards),

                const SizedBox(height: 32),

                // Kreisdiagramm: Ausgaben-Kategorien
                ExpenseChartSection(expenseSlices: _state.pieSlices),

                const SizedBox(height: 32),

                // Karte: aktuelle Schulden Details
                DebtsList(summary: summary),

                const SizedBox(height: 24),

                // Event-Vorschläge (Karten)
                EventSuggestionsList(suggestions: _state.suggestions),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      // Button: Rechnung teilen (hinzufügen)
      floatingActionButton: AddBillFab(onPressed: _showAddBillDialog),
    );
  }

  // Platzhalter für die Funktion 'Rechnungen hinzuzufügen'
  void _showAddBillDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechnung teilen'),
        content: const Text(
          'Hier würdest du eine neue Rechnung mit Freunden teilen können:\n\n'
          '📷 Foto machen oder auswählen\n'
          '🤖 OCR zum automatischen Auslesen\n'
          '👥 Freunde auswählen\n'
          '💰 Beträge aufteilen\n'
          '📅 Event zuordnen',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature kommt bald! 🚀')),
              );
            },
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }
}
