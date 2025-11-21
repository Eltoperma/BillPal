import 'package:flutter/foundation.dart' show kDebugMode;
import '../../../../../core/logging/app_logger.dart';

/// Result of quantity extraction from a line
class QuantityExtractionResult {
  final int quantity;
  final String description;
  final String pattern; // 'prefix' or 'suffix'

  const QuantityExtractionResult({
    required this.quantity,
    required this.description,
    required this.pattern,
  });
}

/// Strategy for extracting quantity information from text lines
///
/// Supports patterns:
/// - Prefix: "2x Item", "2 x Item", "2xItem"
/// - Suffix: "Item x2", "Item x 2", "Itemx2"
class QuantityExtractionStrategy {
  static const AppLogger _logger = AppLogger.parser;

  static final _quantityPrefixPattern = RegExp(
    r'^(\d+)\s*[xX×*]\s*(.+)',
    caseSensitive: false,
  );
  
  static final _quantitySuffixPattern = RegExp(
    r'(.+?)\s*[xX×*]\s*(\d+)$',
    caseSensitive: false,
  );

  /// Extract quantity information from line
  ///
  /// Returns null if no quantity pattern is found (implying quantity of 1).
  /// Returns a QuantityExtractionResult with the quantity, description, and pattern type.
  QuantityExtractionResult? extractQuantity(String line) {
    if (kDebugMode) {
      _logger.debug('      🔍 Checking for quantity pattern in: "$line"');
    }

    // Check prefix pattern: "2x Item" or "2 x Item"
    var match = _quantityPrefixPattern.firstMatch(line);
    if (match != null) {
      final quantity = int.parse(match.group(1)!);
      final description = match.group(2)!.trim();

      if (kDebugMode) {
        _logger.debug(
          '      ✅ Found PREFIX pattern: ${quantity}x "$description"',
        );
      }

      return QuantityExtractionResult(
        quantity: quantity,
        description: description,
        pattern: 'prefix',
      );
    }

    // Check suffix pattern: "Item x2" or "Item x 2"
    match = _quantitySuffixPattern.firstMatch(line);
    if (match != null) {
      final quantity = int.parse(match.group(2)!);
      final description = match.group(1)!.trim();

      if (kDebugMode) {
        _logger.debug(
          '      ✅ Found SUFFIX pattern: ${quantity}x "$description"',
        );
      }

      return QuantityExtractionResult(
        quantity: quantity,
        description: description,
        pattern: 'suffix',
      );
    }

    if (kDebugMode) {
      _logger.debug('      ❌ No quantity pattern found');
    }

    // No quantity pattern found - default to 1
    return null;
  }

  /// Check if a line contains a quantity pattern
  bool hasQuantityPattern(String line) {
    return _quantityPrefixPattern.hasMatch(line) || 
           _quantitySuffixPattern.hasMatch(line);
  }
}

