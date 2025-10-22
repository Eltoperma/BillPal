import 'package:billpal/features/bills/presentation/entrypoint/add_invoice_entrypoint.dart';
import 'package:billpal/features/dashboard/application/dashboard_controller.dart';
import 'package:billpal/features/dashboard/presentation/widgets/debts_list.dart';
import 'package:billpal/features/dashboard/presentation/widgets/expense_chart_section.dart';
import 'package:billpal/features/dashboard/presentation/widgets/header.dart';
import 'package:billpal/features/dashboard/presentation/widgets/summary_cards.dart';
import 'package:billpal/features/dashboard/presentation/widgets/recent_bills_list.dart';
import 'package:billpal/features/friends/presentation/widgets/friends_preview_card.dart';
import 'package:billpal/features/settings/presentation/widgets/app_drawer.dart';
import 'package:billpal/l10n/locale_controller.dart';
import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/core/logging/app_logger.dart';
import 'package:billpal/shared/application/services.dart';
import 'package:billpal/core/theme/theme_controller.dart';
import 'package:billpal/core/app_mode/app_mode_service.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final ThemeController themeController;
  final LocaleController localeController;
  const DashboardPage({
    super.key,
    required this.themeController,
    required this.localeController,
  });

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
    
    // Listener für Mode-Changes
    AppModeService().addListener(_onModeChanged);
    
    _reload();
  }

  @override
  void dispose() {
    AppModeService().removeListener(_onModeChanged);
    super.dispose();
  }

  /// Callback bei Mode-Wechsel - lädt Dashboard neu
  void _onModeChanged() {
    AppLogger.dashboard.info('🔄 Dashboard: Mode gewechselt zu ${AppModeService().currentMode.name} - Reload');
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
    final sc = Theme.of(context).colorScheme;

    if (_state.isLoading || _state.summary == null) {
      return Scaffold(
        backgroundColor: sc.surface,
        endDrawer: AppDrawer(
          themeController: widget.themeController,
          localeController: widget.localeController,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final summary = _state.summary!;

    return Scaffold(
      backgroundColor: sc.surface,
      endDrawer: AppDrawer(
        themeController: widget.themeController,
        localeController: widget.localeController,
      ),
      body: SafeArea(
        child: Builder(
          builder: (ctx) => RefreshIndicator(
            onRefresh: _reload,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: DashboardHeader(summary: summary)),
                      const SizedBox(width: 8),
                      // TODO: [CLEANUP] Debug-Info entfernen nach Branch-Cleanup
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppModeService().isDemoMode ? Colors.orange.shade100 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppModeService().currentMode.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppModeService().isDemoMode ? Colors.orange.shade800 : Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // DEBUG: Real-Mode Switch Button
                          // TODO: [CLEANUP] Nach Testing entfernen
                          if (AppModeService().currentMode == AppMode.demo)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.rocket_launch, size: 14),
                              label: const Text('Real', style: TextStyle(fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: const Size(60, 28),
                              ),
                              onPressed: () async {
                                await AppModeService().forceRealMode();
                                setState(() {}); // UI refresh
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🚀 Real-Mode aktiviert! Echte Datenbank wird verwendet.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 4),
                          IconButton(
                            tooltip: 'Menu',
                            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                            icon: const Icon(Icons.menu),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Karten: Schulden-Übersicht
                  SummaryCards(cards: _state.summaryCards),

                  const SizedBox(height: 32),

                  // TODO: [CLEANUP] Friends Card nach Branch-Cleanup optional machen
                  // Freunde-Vorschau (Collapsible)
                  const FriendsPreviewCard(),

                  const SizedBox(height: 32),

                  // Kreisdiagramm: Ausgaben-Kategorien
                  ExpenseChartSection(expenseSlices: _state.pieSlices),

                  const SizedBox(height: 32),

                  // Karte: aktuelle Schulden Details
                  DebtsList(summary: summary),

                  const SizedBox(height: 32),

                  // Karte: Letzte Rechnungen
                  RecentBillsList(summary: summary),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),

      // Button: Rechnung teilen (hinzufügen)
      // TODO: [CLEANUP] Nach vollständiger Migration Mock-Logik entfernen
      floatingActionButton: FutureBuilder<List<Person>>(
        future: UserService().getAllFriends(), // UserService statt BillSharingService!
        builder: (context, snapshot) {
          final people = snapshot.data ?? [];
          return AddInvoiceEntryButton(people: people);
        },
      ),
    );
  }
}
