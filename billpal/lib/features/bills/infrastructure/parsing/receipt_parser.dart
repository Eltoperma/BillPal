import '../ocr/receipt_data.dart';

class ReceiptParser {
  static final _pricePattern = RegExp(r'(\d+)[.,](\d{2})(?:\s*€)?');
  static final _quantityPrefixPattern = RegExp(
    r'^(\d+)\s*x\s+(.+)',
    caseSensitive: false,
  );
  static final _quantitySuffixPattern = RegExp(
    r'(.+?)\s+x\s*(\d+)$',
    caseSensitive: false,
  );

  static final _totalKeywords = [
    'total',
    'summe',
    'gesamt',
    'sum',
    'betrag',
    'zahlen',
    'zu zahlen',
    'endbetrag',
  ];

  ReceiptData parse(String rawText) {
    if (rawText.trim().isEmpty) {
      return ReceiptData(items: const [], rawText: rawText);
    }

    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return ReceiptData(items: const [], rawText: rawText);
    }

    final restaurantName = _extractRestaurantName(lines);
    final total = _extractTotal(lines);
    final items = _extractLineItems(lines, total);

    return ReceiptData(
      restaurantName: restaurantName,
      items: items,
      total: total,
      rawText: rawText,
    );
  }

  String? _extractRestaurantName(List<String> lines) {
    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i];
      if (_isProbablyName(line)) {
        return line;
      }
    }
    return null;
  }

  bool _isProbablyName(String line) {
    if (line.length < 3) return false;
    final letters = line.replaceAll(RegExp(r'[^a-zA-ZäöüÄÖÜß]'), '');
    return letters.length >= line.length * 0.6;
  }

  double? _extractTotal(List<String> lines) {
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].toLowerCase();
      final hasKeyword = _totalKeywords.any(
        (keyword) => line.contains(keyword),
      );

      if (hasKeyword) {
        final price = _extractPriceFromLine(lines[i]);
        if (price != null) {
          return price;
        }
      }
    }

    // Fallback: largest price in last 10 lines
    double? largestPrice;
    for (final line in lines.reversed.take(10)) {
      final price = _extractPriceFromLine(line);
      if (price != null) {
        if (largestPrice == null || price > largestPrice) {
          largestPrice = price;
        }
      }
    }

    return largestPrice;
  }

  List<ReceiptLineItem> _extractLineItems(List<String> lines, double? total) {
    final items = <ReceiptLineItem>[];

    for (final line in lines) {
      if (_isLikelyHeaderOrFooter(line)) continue;

      final item = _parseLineItem(line);
      if (item != null) {
        // Don't include the total as a line item
        if (total != null && item.totalPrice != null) {
          if ((item.totalPrice! - total).abs() < 0.01) {
            continue;
          }
        }
        items.add(item);
      }
    }

    return items;
  }

  bool _isLikelyHeaderOrFooter(String line) {
    final lower = line.toLowerCase();

    if (_totalKeywords.any((k) => lower.contains(k))) return true;
    if (lower.contains('uhrzeit') || lower.contains('datum')) return true;
    if (lower.contains('mwst') || lower.contains('steuer')) return true;
    if (lower.contains('betrag') && !_pricePattern.hasMatch(line)) return true;
    if (lower.contains('vielen dank') || lower.contains('thank you')) {
      return true;
    }
    if (lower.contains('auf wiedersehen') || lower.contains('goodbye')) {
      return true;
    }

    return false;
  }

  ReceiptLineItem? _parseLineItem(String line) {
    // Quantity prefix: "2x Pizza Margherita 9.50"
    var match = _quantityPrefixPattern.firstMatch(line);
    if (match != null) {
      final quantity = int.parse(match.group(1)!);
      final rest = match.group(2)!;
      final price = _extractPriceFromLine(rest);

      if (price != null) {
        final description = rest.replaceAll(_pricePattern, '').trim();
        return ReceiptLineItem(
          description: description,
          quantity: quantity,
          totalPrice: price,
          unitPrice: price / quantity,
        );
      }
    }

    // Quantity suffix: "Pizza Margherita x2 9.50"
    match = _quantitySuffixPattern.firstMatch(line);
    if (match != null) {
      final description = match.group(1)!.trim();
      final quantity = int.parse(match.group(2)!);
      final price = _extractPriceFromLine(line);

      if (price != null) {
        final cleanDescription = description
            .replaceAll(_pricePattern, '')
            .trim();
        return ReceiptLineItem(
          description: cleanDescription,
          quantity: quantity,
          totalPrice: price,
          unitPrice: price / quantity,
        );
      }
    }

    // Standard: "Pizza Margherita 9.50"
    final price = _extractPriceFromLine(line);
    if (price != null && price > 0) {
      final description = line.replaceAll(_pricePattern, '').trim();

      if (description.length >= 2) {
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

  double? _extractPriceFromLine(String line) {
    final match = _pricePattern.firstMatch(line);
    if (match == null) return null;

    final euros = match.group(1)!;
    final cents = match.group(2)!;

    return double.parse('$euros.$cents');
  }
}
