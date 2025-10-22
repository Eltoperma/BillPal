import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/services/finance_service.dart';
import 'package:billpal/services/invoice_service.dart';
import 'package:flutter/foundation.dart';

/// Alles, was das Dashboard braucht – ohne Widgets.
@immutable
class DashboardState {
  final bool isLoading;
  final BillSharingSummary? summary;
  final List<SummaryCard> summaryCards;
  final List<PieSlice> pieSlices;
  final List<EventSuggestion> suggestions;

  const DashboardState({
    required this.isLoading,
    this.summary,
    this.summaryCards = const [],
    this.pieSlices = const [],
    this.suggestions = const [],
  });

  DashboardState copyWith({
    bool? isLoading,
    BillSharingSummary? summary,
    List<SummaryCard>? summaryCards,
    List<PieSlice>? pieSlices,
    List<EventSuggestion>? suggestions,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      summaryCards: summaryCards ?? this.summaryCards,
      pieSlices: pieSlices ?? this.pieSlices,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

/// Schlichte Controller-Klasse ohne Packages.
/// (Wenn ihr später Riverpod nehmt, wird das eine StateNotifier.)
class DashboardController {
  final BillSharingAnalyticsService analytics;
  final BillSharingService bills;

  DashboardController({
    required this.analytics,
    required this.bills,
  });

  /// Initiales Laden (Demo-Daten + Analytics).
  Future<DashboardState> load() async {
    // Demo-Daten initialisieren (jetzt async)
    await bills.initializeDemoData();

    // Daten holen (jetzt async)
    final summary = await analytics.getDashboardSummary();
    final cards = await analytics.getSummaryCards();
    final pie = await analytics.getExpensePieSlices(); // Jetzt async!
    final suggestions = analytics.getEventSuggestions();

    return DashboardState(
      isLoading: false,
      summary: summary,
      summaryCards: cards,
      pieSlices: pie,
      suggestions: suggestions,
    );
  }
}
