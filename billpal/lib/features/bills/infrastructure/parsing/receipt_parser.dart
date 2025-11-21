import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../ocr/receipt_data.dart';
import '../../../../core/logging/app_logger.dart';
import 'strategies/price_extraction_strategy.dart';
import 'strategies/quantity_extraction_strategy.dart';
import 'strategies/restaurant_name_extraction_strategy.dart';
import 'strategies/total_extraction_strategy.dart';
import 'strategies/header_footer_detection_strategy.dart';
import 'strategies/line_item_extraction_strategy.dart';

/// Modular receipt parser using specialized parsing strategies
///
/// Each parsing aspect is handled by its own strategy module:
/// - Price extraction (various formats)
/// - Quantity extraction (prefix/suffix patterns)
/// - Restaurant name detection
/// - Total amount detection
/// - Header/footer filtering
/// - Line item extraction
///
/// This modular approach makes it easier to optimize and test
/// specific parsing strategies independently.
class ReceiptParser {
  static const AppLogger _logger = AppLogger.parser;

  // Strategy modules
  final PriceExtractionStrategy _priceStrategy;
  final RestaurantNameExtractionStrategy _restaurantNameStrategy;
  final TotalExtractionStrategy _totalStrategy;
  final LineItemExtractionStrategy _lineItemStrategy;

  ReceiptParser({
    PriceExtractionStrategy? priceStrategy,
    QuantityExtractionStrategy? quantityStrategy,
    RestaurantNameExtractionStrategy? restaurantNameStrategy,
    TotalExtractionStrategy? totalStrategy,
    HeaderFooterDetectionStrategy? headerFooterStrategy,
    LineItemExtractionStrategy? lineItemStrategy,
  }) : _priceStrategy = priceStrategy ?? PriceExtractionStrategy(),
       _restaurantNameStrategy =
           restaurantNameStrategy ?? RestaurantNameExtractionStrategy(),
       _totalStrategy = totalStrategy ?? TotalExtractionStrategy(),
       _lineItemStrategy =
           lineItemStrategy ??
           LineItemExtractionStrategy(
             priceStrategy: priceStrategy,
             quantityStrategy: quantityStrategy,
             headerFooterStrategy: headerFooterStrategy,
           );

  ReceiptData parse(String rawText) {
    _logger.info('🔍 Starting receipt parsing...');

    if (rawText.trim().isEmpty) {
      _logger.warning('⚠️ Empty text received');
      return ReceiptData(items: const [], rawText: rawText);
    }

    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      _logger.warning('⚠️ No valid lines after processing');
      return ReceiptData(items: const [], rawText: rawText);
    }

    _logger.debug('📄 Processing ${lines.length} lines');

    if (kDebugMode) {
      _debugLogInputLines(lines);
    }

    final restaurantName = _restaurantNameStrategy.extractRestaurantName(lines);
    final total = _totalStrategy.extractTotal(lines);
    final items = _lineItemStrategy.extractLineItems(lines, total);

    final receiptData = ReceiptData(
      restaurantName: restaurantName,
      items: items,
      total: total,
      rawText: rawText,
    );

    _logger.success(
      '✅ Parsing complete: ${items.length} items found, '
      'total: ${total?.toStringAsFixed(2) ?? "N/A"}€',
    );

    if (kDebugMode) {
      _debugLogParsedData(receiptData);
    }

    return receiptData;
  }

  /// Debug log input lines
  void _debugLogInputLines(List<String> lines) {
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.debug('📄 INPUT LINES (${lines.length} total):');
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    for (int i = 0; i < lines.length; i++) {
      final hasPrice = _priceStrategy.containsPrice(lines[i]);
      final priceIndicator = hasPrice ? ' 💰' : '';
      _logger.debug(
        '[${i.toString().padLeft(3)}]$priceIndicator "${lines[i]}"',
      );
    }

    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  /// Debug log parsed receipt data as JSON
  void _debugLogParsedData(ReceiptData data) {
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    _logger.debug('📊 PARSED RECEIPT DATA (JSON):');
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final jsonData = {
      'restaurantName': data.restaurantName,
      'total': data.total,
      'calculatedTotal': data.calculatedTotal,
      'isTotalConsistent': data.isTotalConsistent,
      'itemCount': data.items.length,
      'items': data.items
          .map(
            (item) => {
              'description': item.description,
              'quantity': item.quantity,
              'unitPrice': item.unitPrice,
              'totalPrice': item.totalPrice,
            },
          )
          .toList(),
    };

    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(jsonData);

    _logger.debug(prettyJson);
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (!data.isTotalConsistent) {
      final diff = (data.total! - data.calculatedTotal).abs();
      _logger.warning(
        '⚠️ TOTAL MISMATCH: Receipt total: ${data.total?.toStringAsFixed(2)}€ '
        'vs Calculated: ${data.calculatedTotal.toStringAsFixed(2)}€ '
        '(diff: ${diff.toStringAsFixed(2)}€)',
      );
    }
  }
}
