import 'package:flutter/material.dart';
import '../models/financial_data.dart';
import '../models/invoice.dart';
import '../services/finance_service.dart';
import '../services/invoice_service.dart';
import '../widgets/financial_info_card.dart';
import '../widgets/pie_chart.dart';

/// Dashboard für geteilte Rechnungen zwischen Freunden
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final BillSharingAnalyticsService _analyticsService = BillSharingAnalyticsService();
  final BillSharingService _billService = BillSharingService();
  
  late BillSharingSummary _summary;
  late List<SummaryCard> _summaryCards;
  late List<ExpensePieSlice> _pieSlices;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Initialisiere Services mit Demo-Daten
    _billService.initializeDemoData();
    
    // Lade Bill-Sharing Daten
    _summary = _analyticsService.getDashboardSummary();
    _summaryCards = _analyticsService.getSummaryCards();
    _pieSlices = _analyticsService.getExpensePieSlices();
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    
    await _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F6F8),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),
                
                // Schulden-Übersicht Karten
                _buildSummaryCards(),
                const SizedBox(height: 32),

                // Ausgaben-Kategorien Kreisdiagramm
                _buildExpenseChart(),
                const SizedBox(height: 32),

                // Aktuelle Schulden Details
                _buildDebtsList(),
                const SizedBox(height: 24),

                // Event-Vorschläge
                _buildEventSuggestions(),
                const SizedBox(height: 100), // Platz für FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BillPal',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Geteilte Rechnungen mit Freunden',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _summary.netBalance >= 0 ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _summary.netBalance >= 0 ? Colors.green.shade200 : Colors.red.shade200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _summary.netBalance >= 0 ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: _summary.netBalance >= 0 ? Colors.green.shade700 : Colors.red.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                _summary.netBalance >= 0 
                    ? 'Du bekommst ${_summary.netBalance.toStringAsFixed(2)}€'
                    : 'Du schuldest ${(-_summary.netBalance).toStringAsFixed(2)}€',
                style: TextStyle(
                  color: _summary.netBalance >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: BillSharingCard(card: _summaryCards[0]), // Du schuldest
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BillSharingCard(card: _summaryCards[1]), // Dir wird geschuldet
        ),
      ],
    );
  }

  Widget _buildExpenseChart() {
    return Center(
      child: Column(
        children: [
          Text(
            'Geteilte Ausgaben',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ExpensePieChart(
            slices: _pieSlices,
            size: 220,
            showLegend: true,
            showLabels: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDebtsList() {
    if (_summary.myDebts.isEmpty && _summary.myCredits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Center(
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Du hast keine offenen Schulden',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
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
          
          // Meine Schulden
          if (_summary.myDebts.isNotEmpty) ...[
            const Text(
              'Du schuldest:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ..._summary.myDebts.map((debt) => _buildDebtItem(debt, false)),
            const SizedBox(height: 16),
          ],
          
          // Was mir geschuldet wird
          if (_summary.myCredits.isNotEmpty) ...[
            const Text(
              'Dir wird geschuldet:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            ..._summary.myCredits.map((debt) => _buildDebtItem(debt, true)),
          ],
        ],
      ),
    );
  }

  Widget _buildDebtItem(Debt debt, bool isCredit) {
    final person = isCredit ? debt.debtor : debt.creditor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: (isCredit ? Colors.green : Colors.red).shade100,
            child: Text(
              person.name[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              person.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${debt.amount.toStringAsFixed(2)}€',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSuggestions() {
    final suggestions = _analyticsService.getEventSuggestions();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event-Vorschläge',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          suggestion.icon,
                          size: 20,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            suggestion.eventName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.formattedDate,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      suggestion.description,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showAddBillDialog,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Rechnung teilen'),
    );
  }

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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature wird bald verfügbar sein! 🚀'),
                ),
              );
            },
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }
}