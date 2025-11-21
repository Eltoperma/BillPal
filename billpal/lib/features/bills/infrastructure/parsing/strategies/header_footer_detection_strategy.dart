import 'price_extraction_strategy.dart';

/// Strategy for detecting header and footer lines that should not be parsed as items
///
/// Identifies lines containing:
/// - Total keywords
/// - Date and time patterns
/// - Tax and VAT information
/// - Payment methods
/// - Greetings
/// - Receipt metadata
/// - Address/contact info
class HeaderFooterDetectionStrategy {
  final PriceExtractionStrategy _priceStrategy;

  static final _sumKeywords = [
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
    'sum',
    'total amount',
    'amount due',
    'balance',
    'grand total',
    'ges.',
    'sum.',
    'tot.',
  ];

  HeaderFooterDetectionStrategy({
    PriceExtractionStrategy? priceStrategy,
  }) : _priceStrategy = priceStrategy ?? PriceExtractionStrategy();

  /// Check if a line is likely a header or footer
  ///
  /// Returns true if the line should be skipped during item extraction.
  bool isLikelyHeaderOrFooter(String line) {
    final lower = line.toLowerCase();

    // Total keywords - but ONLY if they match as whole words to avoid false positives
    // e.g., "bar" in "Rhabarber" should not match
    for (final keyword in _sumKeywords) {
      final keywordLower = keyword.toLowerCase();
      // Check if keyword appears as whole word (with word boundaries)
      if (RegExp(r'\b' + RegExp.escape(keywordLower) + r'\b').hasMatch(lower)) {
        return true;
      }
    }

    // Date and time - more specific patterns
    if (RegExp(r'\b(datum|date|uhrzeit|time)\b').hasMatch(lower)) return true;
    if (RegExp(r'\d{1,2}[.:/]\d{1,2}[.:/]\d{2,4}').hasMatch(line))
      return true; // Date patterns
    // Time pattern but not a price
    if (RegExp(r'\d{1,2}:\d{2}').hasMatch(line) &&
        !_priceStrategy.containsPrice(line))
      return true;

    // Tax and VAT - whole word matching
    if (RegExp(r'\b(mwst|steuer|vat|tax|ust)\b').hasMatch(lower)) return true;

    // Amount without price (header)
    if (lower.contains('betrag') && !_priceStrategy.containsPrice(line))
      return true;

    // Payment method - more specific to avoid false positives
    if (RegExp(
      r'\b(bar|karte|card)\s+(zahlung|payment|bezahlt|paid)',
    ).hasMatch(lower))
      return true;
    if (lower.contains('kartenzahlung') || lower.contains('barzahlung'))
      return true;
    if (lower.contains('wechselgeld') || lower.contains('rückgeld'))
      return true;

    // Greetings - full phrases only
    if (lower.contains('vielen dank') ||
        lower.contains('thank you') ||
        lower.contains('auf wiedersehen') ||
        lower.contains('goodbye'))
      return true;

    // Receipt metadata - whole word only
    if (RegExp(r'\b(bon|beleg|kasse|kellner|server)\b').hasMatch(lower))
      return true;
    if (lower.startsWith('tisch') && lower.length < 10)
      return true; // "Tisch 5" but not "Tischreservierung Salat"

    // Address/contact info patterns
    if (lower.contains('tel') || lower.contains('fax')) return true;
    if (lower.contains('str.') || lower.contains('@') || lower.contains('www.'))
      return true;
    if (RegExp(r'\b\d{5}\s+[a-zäöüß]+\b').hasMatch(lower))
      return true; // PLZ Stadt pattern

    // Very short lines (likely noise or formatting)
    if (line.length <= 2) return true;

    // Lines with only special characters or numbers
    if (RegExp(r'^[*\-=_\.]+$').hasMatch(line)) return true;
    if (RegExp(r'^\d+$').hasMatch(line))
      return true; // Just a number, no price format

    return false;
  }
}

