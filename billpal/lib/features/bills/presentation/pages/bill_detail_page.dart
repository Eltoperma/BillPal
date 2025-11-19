import 'package:flutter/material.dart';
import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/shared/application/services.dart';
import 'package:billpal/shared/application/services/configurable_category_service.dart';
import 'package:billpal/shared/application/services/multi_language_category_service.dart';
import 'package:billpal/shared/presentation/dialogs/category_selection_dialog.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/currency.dart';
import 'package:intl/intl.dart';

/// Detailansicht einer einzelnen Rechnung mit Posten und Settlement-Funktionen
class BillDetailPage extends StatefulWidget {
  final SharedBill bill;
  
  const BillDetailPage({
    super.key,
    required this.bill,
  });

  @override
  State<BillDetailPage> createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  final BillSharingService _billService = BillSharingService();
  late SharedBill _bill;
  List<BillPosition> _positions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _bill = widget.bill;
    _loadBillDetails();
  }

  Future<void> _loadBillDetails() async {
    setState(() => _isLoading = true);
    
    try {
      _positions = await _billService.getBillPositions(_bill.id);
    } catch (e) {
      AppLogger.bills.error('Fehler beim Laden der Rechnungsdetails: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePositionSettlement(BillPosition position) async {
    try {
      await _billService.updatePositionSettlement(position.id, !position.isSettled);
      
      setState(() {
        position.isSettled = !position.isSettled;
      });
      
      AppLogger.bills.info('Position "${position.description}" ${position.isSettled ? "als beglichen markiert" : "als offen markiert"}');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(position.isSettled 
            ? '✅ Position als beglichen markiert'
            : '🔄 Position als offen markiert'),
          duration: const Duration(seconds: 2),
        ),
      );
      
    } catch (e) {
      AppLogger.bills.error('Fehler beim Aktualisieren des Settlement-Status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Fehler beim Speichern'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showCategoryDialog() async {
    final currentLocale = CategoryLocaleService.getCurrentLocale(context);
    final currentCategory = ConfigurableCategoryService.categorizeTitle(_bill.title, locale: currentLocale);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => CategorySelectionDialog(
        currentCategory: currentCategory,
        billTitle: _bill.title,
      ),
    );

    if (result != null && result != currentCategory) {
      // User hat Kategorie korrigiert
      final userService = MultiLanguageUserCategoryService();
      await userService.addCorrection(_bill.title, currentCategory, result, currentLocale);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Kategorie zu "$result" geändert'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_bill.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Kategorie bearbeiten',
            onPressed: _showCategoryDialog,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBillHeader(),
                const SizedBox(height: 24),
                _buildPositionsList(),
                const SizedBox(height: 24),
                _buildSummaryCard(),
              ],
            ),
          ),
    );
  }

  Widget _buildBillHeader() {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'de_DE');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _bill.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Bezahlt von ${_bill.paidBy.name}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(_bill.date),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.euro, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Gesamtsumme: ${euro(_bill.totalAmount)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Positionen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._positions.map((position) => _buildPositionCard(position)),
      ],
    );
  }

  Widget _buildPositionCard(BillPosition position) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: position.isSettled,
          onChanged: (_) => _togglePositionSettlement(position),
          activeColor: Colors.green,
        ),
        title: Text(
          position.description,
          style: TextStyle(
            decoration: position.isSettled ? TextDecoration.lineThrough : null,
            color: position.isSettled ? Colors.grey.shade600 : null,
          ),
        ),
        subtitle: Text(
          'Zugeordnet an: ${position.assignedTo.name}',
          style: TextStyle(
            color: position.isSettled ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              euro(position.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: position.isSettled ? TextDecoration.lineThrough : null,
                color: position.isSettled ? Colors.grey.shade600 : null,
              ),
            ),
            if (position.isSettled)
              const Text(
                '✅ Beglichen',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              const Text(
                '⏳ Offen',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final settledPositions = _positions.where((p) => p.isSettled).toList();
    final openPositions = _positions.where((p) => !p.isSettled).toList();
    
    final settledAmount = settledPositions.fold<double>(0, (sum, p) => sum + p.amount);
    final openAmount = openPositions.fold<double>(0, (sum, p) => sum + p.amount);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Zusammenfassung',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Offene Posten:'),
                Text(
                  '${openPositions.length} (${euro(openAmount)})',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Beglichene Posten:'),
                Text(
                  '${settledPositions.length} (${euro(settledAmount)})',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gesamtsumme:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  euro(_bill.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_bill.status) {
      case BillStatus.settled:
        return Colors.green;
      case BillStatus.shared:
        return Colors.orange;
      case BillStatus.draft:
        return Colors.grey;
      case BillStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText() {
    return _bill.status.displayName;
  }
}