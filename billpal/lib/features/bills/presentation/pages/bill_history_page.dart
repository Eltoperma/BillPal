import 'package:flutter/material.dart';
import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/shared/application/services.dart';
import '../../../../core/logging/app_logger.dart';
import 'package:billpal/core/utils/currency.dart';
import 'package:intl/intl.dart';
import 'bill_detail_page.dart';

/// Vollständige Rechnungshistorie-Seite
class BillHistoryPage extends StatefulWidget {
  final String? filterBy; // 'owed_to_me', 'i_owe', 'paid_by_me'
  final BillStatus? statusFilter;
  
  const BillHistoryPage({
    super.key,
    this.filterBy,
    this.statusFilter,
  });

  @override
  State<BillHistoryPage> createState() => _BillHistoryPageState();
}

class _BillHistoryPageState extends State<BillHistoryPage> {
  final BillSharingService _analyticsService = BillSharingService();
  
  List<SharedBill> _allBills = [];
  List<SharedBill> _filteredBills = [];
  bool _isLoading = true;
  String _searchQuery = '';
  BillStatus? _selectedStatus;
  String _sortBy = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc

  @override
  void initState() {
    super.initState();
    
    // Setze voreingestellte Filter basierend auf Parametern
    if (widget.statusFilter != null) {
      _selectedStatus = widget.statusFilter;
    }
    
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);
    
    try {
      _allBills = await _analyticsService.getAllSharedBills();
      _applyFilters();
    } catch (e) {
      AppLogger.bills.error('Fehler beim Laden der Rechnungen: $e');
    }
    
    setState(() => _isLoading = false);
  }

  bool _matchesSpecialFilter(SharedBill bill, String filterBy) {
    // Verwende Name-basierten Vergleich da User-ID inkonsistent ist
    final isMyBill = bill.paidBy.name == "Ich" || bill.paidBy.name.contains("Ich");
    
    switch (filterBy) {
      case 'owed_to_me':
        // Alle Rechnungen die ICH bezahlt habe
        // = Dir wird geschuldet (du hast bezahlt, andere schulden dir)
        return isMyBill;
      
      case 'i_owe':
        // Alle Rechnungen die ANDERE bezahlt haben
        // = Du schuldest (andere haben bezahlt, du schuldest ihnen)
        return !isMyBill;
      
      case 'paid_by_me':
        // Alle Rechnungen die ich bezahlt habe
        return isMyBill;
      
      default:
        return true;
    }
  }

  String _getPageTitle() {
    if (widget.filterBy != null) {
      switch (widget.filterBy!) {
        case 'owed_to_me':
          return 'Dir wird geschuldet';
        case 'i_owe':
          return 'Du schuldest';
        case 'paid_by_me':
          return 'Von dir bezahlt';
      }
    }
    return 'Rechnungshistorie';
  }

  void _applyFilters() {
    _filteredBills = _allBills.where((bill) {
      // Suchfilter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!bill.title.toLowerCase().contains(query) &&
            !bill.paidBy.name.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Status-Filter
      if (_selectedStatus != null && bill.status != _selectedStatus) {
        return false;
      }
      
      // Spezial-Filter basierend auf Dashboard-Navigation
      if (widget.filterBy != null) {
        if (!_matchesSpecialFilter(bill, widget.filterBy!)) {
          return false;
        }
      }
      
      return true;
    }).toList();

    // Sortierung
    switch (_sortBy) {
      case 'date_desc':
        _filteredBills.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'date_asc':
        _filteredBills.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_desc':
        _filteredBills.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
        break;
      case 'amount_asc':
        _filteredBills.sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
        break;
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onStatusFilterChanged(BillStatus? status) {
    setState(() {
      _selectedStatus = status;
      _applyFilters();
    });
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AppLogger.nav.info('🔙 Zurück-Navigation von BillHistory');
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // Fallback: Wenn nichts zum zurückkehren da ist, gehe zum Dashboard
              AppLogger.nav.debug('Kein Pop möglich, navigiere zum Dashboard');
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
          tooltip: 'Zurück',
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: _onSortChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date_desc',
                child: Text('Neueste zuerst'),
              ),
              const PopupMenuItem(
                value: 'date_asc',
                child: Text('Älteste zuerst'),
              ),
              const PopupMenuItem(
                value: 'amount_desc',
                child: Text('Höchster Betrag'),
              ),
              const PopupMenuItem(
                value: 'amount_asc',
                child: Text('Niedrigster Betrag'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          _buildSearchAndFilterBar(),
          
          // Bills List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBills.isEmpty
                    ? _buildEmptyState()
                    : _buildBillsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Rechnung oder Person suchen...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Alle'),
                  selected: _selectedStatus == null,
                  onSelected: (_) => _onStatusFilterChanged(null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Geteilt'),
                  selected: _selectedStatus == BillStatus.shared,
                  onSelected: (_) => _onStatusFilterChanged(BillStatus.shared),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Beglichen'),
                  selected: _selectedStatus == BillStatus.settled,
                  onSelected: (_) => _onStatusFilterChanged(BillStatus.settled),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Entwurf'),
                  selected: _selectedStatus == BillStatus.draft,
                  onSelected: (_) => _onStatusFilterChanged(BillStatus.draft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedStatus != null
                ? 'Keine Rechnungen gefunden'
                : 'Noch keine Rechnungen vorhanden',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedStatus != null
                ? 'Versuche andere Suchbegriffe oder Filter'
                : 'Erstelle deine erste Rechnung über das Dashboard',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredBills.length,
      itemBuilder: (context, index) {
        final bill = _filteredBills[index];
        return _buildBillCard(bill);
      },
    );
  }

  Widget _buildBillCard(SharedBill bill) {
    final statusColor = _getStatusColor(bill.status);
    final statusIcon = _getStatusIcon(bill.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showBillDetails(bill),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Status Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
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
                  Text(
                    'Bezahlt von ${bill.paidBy.name}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd.MM.yyyy').format(bill.date),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.receipt,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
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
            
            // Amount & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  euro(bill.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(bill.status),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _showBillDetails(SharedBill bill) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BillDetailPage(bill: bill),
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

  String _getStatusText(BillStatus status) {
    switch (status) {
      case BillStatus.draft:
        return 'Entwurf';
      case BillStatus.shared:
        return 'Geteilt';
      case BillStatus.settled:
        return 'Beglichen';
      case BillStatus.cancelled:
        return 'Storniert';
    }
  }
}