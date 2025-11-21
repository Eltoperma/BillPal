import '../../../../../core/logging/app_logger.dart';
import 'price_extraction_strategy.dart';

/// Strategy for extracting restaurant name from receipt text
///
/// Searches the first few lines for a line that looks like a business name.
class RestaurantNameExtractionStrategy {
  static const AppLogger _logger = AppLogger.parser;

  final PriceExtractionStrategy _priceStrategy;

  RestaurantNameExtractionStrategy({
    PriceExtractionStrategy? priceStrategy,
  }) : _priceStrategy = priceStrategy ?? PriceExtractionStrategy();

  /// Extract restaurant name from the top lines of the receipt
  ///
  /// Looks in the first 7 lines for a line that looks like a business name.
  /// Returns null if no suitable name is found.
  String? extractRestaurantName(List<String> lines) {
    _logger.debug('🏪 Extracting restaurant name...');

    // Look in first 7 lines for name
    for (int i = 0; i < lines.length && i < 7; i++) {
      final line = lines[i];
      if (_isProbablyName(line)) {
        _logger.info('✅ Restaurant name found: "$line"');
        return line;
      }
    }

    _logger.debug('⚠️ No restaurant name found');
    return null;
  }

  bool _isProbablyName(String line) {
    // Skip very short lines
    if (line.length < 3) return false;

    // Skip lines with prices
    if (_priceStrategy.containsPrice(line)) return false;

    // Skip lines with numbers only
    if (RegExp(r'^\d+$').hasMatch(line)) return false;

    // Skip common header words
    final lower = line.toLowerCase();
    if (lower.contains('datum') ||
        lower.contains('uhrzeit') ||
        lower.contains('beleg') ||
        lower.contains('kasse') ||
        lower.contains('bon')) {
      return false;
    }

    // Count letters (including German umlauts)
    final letters = line.replaceAll(RegExp(r'[^a-zA-ZäöüÄÖÜßéèê]'), '');

    // Must have at least 60% letters and minimum 4 letters total
    return letters.length >= 4 && letters.length >= line.length * 0.6;
  }
}

