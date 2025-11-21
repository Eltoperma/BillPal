import '../../../../../core/logging/app_logger.dart';
import 'price_extraction_strategy.dart';

/// Strategy for extracting the total amount from receipt text
///
/// Uses multiple strategies:
/// 1. Keyword-based search (looking for "total", "summe", etc.)
/// 2. Fallback: Largest price in the last 15 lines
class TotalExtractionStrategy {
  static const AppLogger _logger = AppLogger.parser;

  final PriceExtractionStrategy _priceStrategy;

  static final _sumKeywords = [
    // German
    'total',
    'summe',
    'gesamt',
    'betrag',
    'zahlen',
    'zu zahlen',
    'endbetrag',
    'gesamtbetrag',
    'brutto',
    'netto',
    'bar',
    'kartenzahlung',
    // English
    'sum',
    'total amount',
    'amount due',
    'balance',
    'grand total',
    // Common abbreviations
    'ges.',
    'sum.',
    'tot.',
  ];

  TotalExtractionStrategy({PriceExtractionStrategy? priceStrategy})
    : _priceStrategy = priceStrategy ?? PriceExtractionStrategy();

  /// Extract total amount from receipt lines
  ///
  /// Strategy 1: Look for keyword-based total (from bottom up)
  /// Strategy 2: If no keyword found, use largest price in last 15 lines
  double? extractTotal(List<String> lines) {
    _logger.debug('💰 Extracting total amount...');

    // Strategy 1: Look for keyword-based total (from bottom up)
    final keywordTotal = _extractTotalByKeyword(lines);
    if (keywordTotal != null) {
      return keywordTotal;
    }

    // Strategy 2: Largest price in last 15 lines
    return _extractLargestPriceInLastLines(lines);
  }

  double? _extractTotalByKeyword(List<String> lines) {
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      final lineLower = line.toLowerCase();

      // Check if line contains a total keyword
      final keyword = _sumKeywords.firstWhere(
        (k) => lineLower.contains(k.toLowerCase()),
        orElse: () => '',
      );

      if (keyword.isNotEmpty) {
        final price = _priceStrategy.extractPrice(line);
        if (price != null && price > 0) {
          _logger.info(
            '✅ Total found with keyword "$keyword": ${price.toStringAsFixed(2)}€',
          );
          return price;
        }

        // Check next line if keyword line has no price
        if (i + 1 < lines.length) {
          final nextPrice = _priceStrategy.extractPrice(lines[i + 1]);
          if (nextPrice != null && nextPrice > 0) {
            _logger.info(
              '✅ Total found (next line after keyword "$keyword"): ${nextPrice.toStringAsFixed(2)}€',
            );
            return nextPrice;
          }
        }
      }
    }

    return null;
  }

  double? _extractLargestPriceInLastLines(List<String> lines) {
    _logger.debug('🔍 Using fallback: finding largest price in last 15 lines');

    double? largestPrice;
    int? largestPriceIndex;

    final lastLines = lines.length > 15
        ? lines.sublist(lines.length - 15)
        : lines;

    for (int i = 0; i < lastLines.length; i++) {
      final price = _priceStrategy.extractPrice(lastLines[i]);
      if (price != null && price > 0) {
        if (largestPrice == null || price > largestPrice) {
          largestPrice = price;
          largestPriceIndex = lines.length - lastLines.length + i;
        }
      }
    }

    if (largestPrice != null) {
      _logger.info(
        '✅ Total found (largest price): ${largestPrice.toStringAsFixed(2)}€ '
        'at line ${largestPriceIndex! + 1}',
      );
    } else {
      _logger.warning('⚠️ No total found');
    }

    return largestPrice;
  }
}
