import '../../../../../core/logging/app_logger.dart';
import '../../ocr/receipt_data.dart';
import 'price_extraction_strategy.dart';
import 'quantity_extraction_strategy.dart';
import 'header_footer_detection_strategy.dart';
import 'number_analysis_strategy.dart';

/// Strategy for extracting line items from receipt text
///
/// Coordinates the extraction process by using other strategies:
/// - HeaderFooterDetectionStrategy: Skip non-item lines
/// - PriceExtractionStrategy: Extract prices
/// - QuantityExtractionStrategy: Extract quantities
/// - NumberAnalysisStrategy: Analyze number relationships for complex items
class LineItemExtractionStrategy {
  static const AppLogger _logger = AppLogger.parser;

  final PriceExtractionStrategy _priceStrategy;
  final QuantityExtractionStrategy _quantityStrategy;
  final HeaderFooterDetectionStrategy _headerFooterStrategy;
  final NumberAnalysisStrategy _numberAnalysisStrategy;

  LineItemExtractionStrategy({
    PriceExtractionStrategy? priceStrategy,
    QuantityExtractionStrategy? quantityStrategy,
    HeaderFooterDetectionStrategy? headerFooterStrategy,
    NumberAnalysisStrategy? numberAnalysisStrategy,
  }) : _priceStrategy = priceStrategy ?? PriceExtractionStrategy(),
       _quantityStrategy = quantityStrategy ?? QuantityExtractionStrategy(),
       _headerFooterStrategy =
           headerFooterStrategy ?? HeaderFooterDetectionStrategy(),
       _numberAnalysisStrategy =
           numberAnalysisStrategy ?? NumberAnalysisStrategy();

  /// Extract all line items from receipt lines
  ///
  /// Skips header/footer lines and the total line.
  /// Handles multi-line items where quantity and price are on separate lines.
  List<ReceiptLineItem> extractLineItems(List<String> lines, double? total) {
    _logger.debug('📝 Extracting line items...');

    final items = <ReceiptLineItem>[];
    int skippedHeaderFooter = 0;
    int skippedTotal = 0;
    int skippedInvalid = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (_headerFooterStrategy.isLikelyHeaderOrFooter(line)) {
        skippedHeaderFooter++;
        continue;
      }

      final item = _parseLineItem(line);
      if (item != null) {
        // Don't include the total as a line item
        if (total != null && item.totalPrice != null) {
          if ((item.totalPrice! - total).abs() < 0.01) {
            _logger.debug(
              '⏭️ Skipping line ${i + 1} (matches total): "${line}"',
            );
            skippedTotal++;
            continue;
          }
        }

        _logger.debug(
          '✅ Line ${i + 1} parsed as item: "${item.description}" - '
          '${item.quantity}x ${item.totalPrice?.toStringAsFixed(2) ?? "N/A"}€',
        );
        items.add(item);
      } else {
        // Check if this line has quantity pattern but no price (multi-column receipt)
        final quantityResult = _quantityStrategy.extractQuantity(line);
        if (quantityResult != null && !_priceStrategy.containsPrice(line)) {
          final multiLineItem = _tryParseMultiLineItem(
            lines,
            i,
            quantityResult.quantity,
            quantityResult.description,
            quantityResult.pattern,
          );

          if (multiLineItem != null) {
            items.add(multiLineItem);
            continue;
          }
        }

        final hasPrice = _priceStrategy.containsPrice(line);
        if (hasPrice) {
          _logger.warning(
            '⚠️ Line ${i + 1} has price but failed to parse: "${line}"',
          );
          skippedInvalid++;
        }
      }
    }

    _logger.info(
      '📊 Extracted ${items.length} items '
      '(skipped: ${skippedHeaderFooter} header/footer, '
      '${skippedTotal} total, ${skippedInvalid} standalone prices)',
    );

    return items;
  }

  /// Parse a single line into a receipt item
  ///
  /// Tries multiple strategies:
  /// 1. Quantity prefix: "2x Pizza Margherita 9.50"
  /// 2. Quantity suffix: "Pizza Margherita x2 9.50"
  /// 3. Number analysis: "2 x 0,5 zipfer 8,40" (uses all numbers)
  /// 4. Standard format: "Pizza Margherita 9.50"
  ReceiptLineItem? _parseLineItem(String line) {
    final quantityResult = _quantityStrategy.extractQuantity(line);

    // Strategy 1 & 2: Quantity patterns (prefix or suffix)
    if (quantityResult != null) {
      final price = _priceStrategy.extractPrice(line);

      if (price != null && price > 0) {
        var description = _priceStrategy.removePriceFromLine(line);

        // Remove quantity pattern from description
        description = description
            .replaceAll(RegExp(r'^\d+\s*[xX×*]\s*'), '') // prefix
            .replaceAll(RegExp(r'\s*[xX×*]\s*\d+$'), '') // suffix
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

        if (description.isNotEmpty) {
          _logger.debug(
            '   → Extracted quantity: ${quantityResult.quantity}x from ${quantityResult.pattern} pattern',
          );
          return ReceiptLineItem(
            description: description,
            quantity: quantityResult.quantity,
            totalPrice: price,
            unitPrice: price / quantityResult.quantity,
          );
        }
      }
    }

    // Strategy 3: Number analysis - extract ALL numbers and analyze relationships
    // This handles ambiguous cases like "2 x 0,5 zipfer 8,40"
    final allNumbers = _numberAnalysisStrategy.extractAllNumbers(line);
    if (allNumbers.length >= 2) {
      final analysis = _numberAnalysisStrategy.analyzeNumbers(line, allNumbers);

      // Use number analysis if confidence is high enough
      if (analysis.confidence >= 0.75 &&
          analysis.mostLikelyTotal != null &&
          analysis.mostLikelyQuantity != null) {
        // Extract description by removing all numbers
        var description = line;
        for (final number in allNumbers) {
          // Remove the number and its surrounding patterns
          if (number == number.toInt().toDouble()) {
            // Integer
            final intValue = number.toInt().toString();
            description = description.replaceAll(RegExp('\\b$intValue\\b'), '');
          } else {
            // Decimal - remove with both comma and dot formats
            final intPart = number.truncate();
            final decimalPart = ((number - intPart) * 100).round();
            final decimalStr = decimalPart.toString().padLeft(2, '0');
            description = description.replaceAll(
              RegExp('$intPart[.,]\\s*$decimalStr'),
              '',
            );
          }
        }

        // Clean up description
        description = description
            .replaceAll(RegExp(r'[xX×*]'), '')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

        if (description.isNotEmpty && description.length <= 150) {
          _logger.debug(
            '   → Number analysis: ${analysis.mostLikelyQuantity}x '
            '× ${analysis.mostLikelyUnitPrice?.toStringAsFixed(2)}€ '
            '= ${analysis.mostLikelyTotal?.toStringAsFixed(2)}€ '
            '(confidence: ${(analysis.confidence * 100).toStringAsFixed(0)}%)',
          );

          return ReceiptLineItem(
            description: description,
            quantity: analysis.mostLikelyQuantity!,
            totalPrice: analysis.mostLikelyTotal,
            unitPrice: analysis.mostLikelyUnitPrice,
          );
        }
      }
    }

    // Strategy 4: Standard format: "Pizza Margherita 9.50"
    final price = _priceStrategy.extractPrice(line);
    if (price != null && price > 0) {
      var description = _priceStrategy.removePriceFromLine(line);

      // Remove common prefixes (article numbers, etc.)
      description = description.replaceAll(RegExp(r'^[\d\-]+\s+'), '');

      // Clean up extra whitespace
      description = description.replaceAll(RegExp(r'\s+'), ' ').trim();

      // Must have reasonable description length - RELAXED to allow single char like "A", "B" (item codes)
      if (description.isNotEmpty && description.length <= 150) {
        // Reject if description is ONLY numbers (likely article number without name)
        if (RegExp(r'^\d+$').hasMatch(description)) {
          return null;
        }

        return ReceiptLineItem(
          description: description,
          quantity: 1,
          totalPrice: price,
          unitPrice: price,
        );
      }
    }

    return null;
  }

  /// Try to parse multi-line item (quantity on one line, price on another)
  ///
  /// Looks ahead up to 3 lines for a standalone price.
  ReceiptLineItem? _tryParseMultiLineItem(
    List<String> lines,
    int currentIndex,
    int quantity,
    String description,
    String pattern,
  ) {
    _logger.debug(
      '🔍 Line ${currentIndex + 1} has $pattern quantity pattern (${quantity}x) but no price: "${lines[currentIndex]}"',
    );

    // Look ahead up to 3 lines for a standalone price
    double? foundPrice;
    int priceLineOffset = 0;
    for (int j = 1; j <= 3 && currentIndex + j < lines.length; j++) {
      final nextLine = lines[currentIndex + j];
      final nextPrice = _priceStrategy.extractPrice(nextLine);
      // Check if next line is mostly just a price (short line)
      if (nextPrice != null) {
        final lineWithoutPrice = _priceStrategy
            .removePriceFromLine(nextLine)
            .replaceAll(RegExp(r'[\s]+'), '')
            .trim();
        if (lineWithoutPrice.length <= 15) {
          // Mostly just price and maybe units
          foundPrice = nextPrice;
          priceLineOffset = j;
          break;
        }
      }
    }

    if (foundPrice != null) {
      _logger.debug(
        '🔗 Line ${currentIndex + 1} matched with price on line ${currentIndex + 1 + priceLineOffset}: '
        '"$description" - ${quantity}x ${foundPrice.toStringAsFixed(2)}€ '
        '(unit: ${(foundPrice / quantity).toStringAsFixed(2)}€)',
      );
      return ReceiptLineItem(
        description: description,
        quantity: quantity,
        totalPrice: foundPrice,
        unitPrice: foundPrice / quantity,
      );
    } else {
      _logger.warning(
        '⚠️ Line ${currentIndex + 1} has ${quantity}x "$description" but NO price found in next 3 lines!',
      );
      return null;
    }
  }
}
