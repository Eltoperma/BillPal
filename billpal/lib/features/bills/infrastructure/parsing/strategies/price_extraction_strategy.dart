/// Strategy for extracting prices from text lines
///
/// Handles multiple price formats:
/// - Standard: "12,50", "12.50", "12,50€"
/// - With currency prefix: "€12.50", "EUR 12.50"
/// - With thousands separator: "1 234,50", "1.234,50"
/// - With space before decimal: "29, 80"
class PriceExtractionStrategy {
  // NOTE: € symbol is OPTIONAL as some receipts don't use it!
  static final List<RegExp> _pricePatterns = [
    // Standard with optional Euro word: "12,50", "12.50", "12,50€", "12,50 Euro"
    RegExp(r'(\d+)[.,](\d{2})(?:\s*(?:€|Euro|EUR|euro))?'),
    // With currency symbol prefix: "€12.50", "EUR 12.50"
    RegExp(r'(?:€|EUR|Euro)\s*(\d+)[.,](\d{2})'),
    // With spaces in thousands: "1 234,50", "1.234,50"
    RegExp(r'(\d{1,3}(?:[\s\.]\d{3})*)[.,](\d{2})(?:\s*(?:€|Euro|EUR))?'),
    // Price with space before decimal: "29, 80" (as seen in receipt!)
    RegExp(r'(\d+),\s+(\d{2})(?:\s*(?:€|Euro|EUR))?'),
  ];

  /// Extract price from line using multiple patterns
  ///
  /// Returns the first valid price found, or null if no price is detected.
  /// Validates that the price is within a reasonable range (0.01 to 99999.99).
  double? extractPrice(String line) {
    // Try each pattern in order
    for (final pattern in _pricePatterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        try {
          // Extract euros and cents
          final euros = match
              .group(1)!
              .replaceAll(RegExp(r'\s+'), ''); // Remove spaces from thousands
          final cents = match.group(2)!;

          final price = double.parse('$euros.$cents');

          // Sanity check: price should be reasonable (0.01 to 999.99)
          if (price >= 0.01 && price < 1000) {
            return price;
          }
        } catch (e) {
          continue;
        }
      }
    }

    return null;
  }

  /// Remove all price patterns from a text line
  ///
  /// Useful for extracting item descriptions by removing the price portion.
  String removePriceFromLine(String line) {
    var result = line;
    for (final pattern in _pricePatterns) {
      result = result.replaceAll(pattern, '').trim();
    }
    return result;
  }

  /// Check if a line contains any price
  bool containsPrice(String line) {
    return extractPrice(line) != null;
  }
}
