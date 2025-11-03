import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import '../ocr/receipt_data.dart';
import '../../../../core/logging/app_logger.dart';

/// Enhanced receipt parser with improved pattern matching and debugging
/// 
/// Improvements:
/// - Multiple price patterns (handles various formats)
/// - Smarter line item detection with context
/// - Better total detection with multiple strategies
/// - Comprehensive debug logging with JSON output
class ReceiptParser {
  static const AppLogger _logger = AppLogger.parser;
  
  // Enhanced price patterns - matches more variations
  static final List<RegExp> _pricePatterns = [
    // Standard: "12.50", "12,50", "12.50€", "12,50 €"
    RegExp(r'(\d+)[.,](\d{2})\s*€?'),
    // With currency symbol: "€12.50", "EUR 12.50"
    RegExp(r'[€$]\s*(\d+)[.,](\d{2})'),
    // With spaces in thousands: "1 234.50"
    RegExp(r'(\d{1,3}(?:\s\d{3})*)[.,](\d{2})\s*€?'),
    // Alternative format: "12:50" (some receipt printers)
    RegExp(r'(\d+):(\d{2})'),
  ];
  
  static final _quantityPrefixPattern = RegExp(
    r'^(\d+)\s*[xX×]\s+(.+)',
    caseSensitive: false,
  );
  static final _quantitySuffixPattern = RegExp(
    r'(.+?)\s+[xX×]\s*(\d+)$',
    caseSensitive: false,
  );

  // Extended keywords for different languages and formats
  static final _totalKeywords = [
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

    final restaurantName = _extractRestaurantName(lines);
    final total = _extractTotal(lines);
    final items = _extractLineItems(lines, total);

    final receiptData = ReceiptData(
      restaurantName: restaurantName,
      items: items,
      total: total,
      rawText: rawText,
    );

    _logger.success('✅ Parsing complete: ${items.length} items found, '
        'total: ${total?.toStringAsFixed(2) ?? "N/A"}€');
    
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
      final hasPrice = _extractPriceFromLine(lines[i]) != null;
      final priceIndicator = hasPrice ? ' 💰' : '';
      _logger.debug('[${i.toString().padLeft(3)}]$priceIndicator "${lines[i]}"');
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
      'items': data.items.map((item) => {
        'description': item.description,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'totalPrice': item.totalPrice,
      }).toList(),
    };
    
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(jsonData);
    
    _logger.debug(prettyJson);
    _logger.debug('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    if (!data.isTotalConsistent) {
      final diff = (data.total! - data.calculatedTotal).abs();
      _logger.warning('⚠️ TOTAL MISMATCH: Receipt total: ${data.total?.toStringAsFixed(2)}€ '
          'vs Calculated: ${data.calculatedTotal.toStringAsFixed(2)}€ '
          '(diff: ${diff.toStringAsFixed(2)}€)');
    }
  }

  String? _extractRestaurantName(List<String> lines) {
    _logger.debug('🏪 Extracting restaurant name...');
    
    // Look in first 7 lines for name (increased from 5)
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
    if (_extractPriceFromLine(line) != null) return false;
    
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

  double? _extractTotal(List<String> lines) {
    _logger.debug('💰 Extracting total amount...');
    
    // Strategy 1: Look for keyword-based total (from bottom up)
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      final lineLower = line.toLowerCase();
      
      // Check if line contains a total keyword
      final keyword = _totalKeywords.firstWhere(
        (k) => lineLower.contains(k.toLowerCase()),
        orElse: () => '',
      );
      
      if (keyword.isNotEmpty) {
        final price = _extractPriceFromLine(line);
        if (price != null && price > 0) {
          _logger.info('✅ Total found with keyword "$keyword": ${price.toStringAsFixed(2)}€');
          return price;
        }
        
        // Check next line if keyword line has no price
        if (i + 1 < lines.length) {
          final nextPrice = _extractPriceFromLine(lines[i + 1]);
          if (nextPrice != null && nextPrice > 0) {
            _logger.info('✅ Total found (next line after keyword "$keyword"): ${nextPrice.toStringAsFixed(2)}€');
            return nextPrice;
          }
        }
      }
    }

    // Strategy 2: Largest price in last 15 lines (increased from 10)
    _logger.debug('🔍 Using fallback: finding largest price in last 15 lines');
    
    double? largestPrice;
    int? largestPriceIndex;
    
    final lastLines = lines.length > 15 ? lines.sublist(lines.length - 15) : lines;
    
    for (int i = 0; i < lastLines.length; i++) {
      final price = _extractPriceFromLine(lastLines[i]);
      if (price != null && price > 0) {
        if (largestPrice == null || price > largestPrice) {
          largestPrice = price;
          largestPriceIndex = lines.length - lastLines.length + i;
        }
      }
    }

    if (largestPrice != null) {
      _logger.info('✅ Total found (largest price): ${largestPrice.toStringAsFixed(2)}€ '
          'at line ${largestPriceIndex! + 1}');
    } else {
      _logger.warning('⚠️ No total found');
    }

    return largestPrice;
  }

  List<ReceiptLineItem> _extractLineItems(List<String> lines, double? total) {
    _logger.debug('📝 Extracting line items...');
    
    final items = <ReceiptLineItem>[];
    int skippedHeaderFooter = 0;
    int skippedTotal = 0;
    int skippedInvalid = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      if (_isLikelyHeaderOrFooter(line)) {
        skippedHeaderFooter++;
        continue;
      }

      final item = _parseLineItem(line);
      if (item != null) {
        // Don't include the total as a line item
        if (total != null && item.totalPrice != null) {
          if ((item.totalPrice! - total).abs() < 0.01) {
            _logger.debug('⏭️ Skipping line ${i + 1} (matches total): "${line}"');
            skippedTotal++;
            continue;
          }
        }
        
        _logger.debug('✅ Line ${i + 1} parsed as item: "${item.description}" - '
            '${item.quantity}x ${item.totalPrice?.toStringAsFixed(2) ?? "N/A"}€');
        items.add(item);
      } else {
        final hasPrice = _extractPriceFromLine(line) != null;
        if (hasPrice) {
          _logger.debug('⚠️ Line ${i + 1} has price but failed to parse: "${line}"');
          skippedInvalid++;
        }
      }
    }

    _logger.info('📊 Extracted ${items.length} items '
        '(skipped: ${skippedHeaderFooter} header/footer, '
        '${skippedTotal} total, ${skippedInvalid} invalid)');

    return items;
  }

  bool _isLikelyHeaderOrFooter(String line) {
    final lower = line.toLowerCase();

    // Total keywords
    if (_totalKeywords.any((k) => lower.contains(k.toLowerCase()))) return true;
    
    // Date and time
    if (lower.contains('uhrzeit') || 
        lower.contains('datum') || 
        lower.contains('date') || 
        lower.contains('time')) return true;
    
    // Tax and VAT
    if (lower.contains('mwst') || 
        lower.contains('steuer') || 
        lower.contains('vat') || 
        lower.contains('tax') ||
        lower.contains('ust')) return true;
    
    // Amount without price (header)
    if (lower.contains('betrag') && _extractPriceFromLine(line) == null) return true;
    
    // Payment method
    if (lower.contains('bar') && lower.contains('zahlung')) return true;
    if (lower.contains('karte') || lower.contains('card')) return true;
    if (lower.contains('wechselgeld') || lower.contains('change')) return true;
    if (lower.contains('rückgeld')) return true;
    
    // Greetings
    if (lower.contains('vielen dank') || 
        lower.contains('danke') ||
        lower.contains('thank you') ||
        lower.contains('thanks')) return true;
    if (lower.contains('auf wiedersehen') || 
        lower.contains('goodbye') ||
        lower.contains('tschüss')) return true;
    
    // Receipt metadata
    if (lower.contains('bon') || lower.contains('beleg')) return true;
    if (lower.contains('kasse') || lower.contains('tisch')) return true;
    if (lower.contains('kellner') || lower.contains('server')) return true;
    
    // Address/contact info patterns
    if (lower.contains('tel') || lower.contains('fax')) return true;
    if (lower.contains('str.') || lower.contains('straße') || lower.contains('strasse')) return true;
    if (lower.contains('@') || lower.contains('www.')) return true;
    
    // Very short lines (likely noise or formatting)
    if (line.length <= 2) return true;
    
    // Lines with only special characters
    if (RegExp(r'^[*\-=_\.]+$').hasMatch(line)) return true;

    return false;
  }

  ReceiptLineItem? _parseLineItem(String line) {
    // Strategy 1: Quantity prefix: "2x Pizza Margherita 9.50"
    var match = _quantityPrefixPattern.firstMatch(line);
    if (match != null) {
      final quantity = int.parse(match.group(1)!);
      final rest = match.group(2)!;
      final price = _extractPriceFromLine(rest);

      if (price != null && price > 0) {
        var description = rest;
        
        // Remove price from description using all patterns
        for (final pattern in _pricePatterns) {
          description = description.replaceAll(pattern, '').trim();
        }
        
        // Clean up extra whitespace
        description = description.replaceAll(RegExp(r'\s+'), ' ').trim();
        
        if (description.length >= 2) {
          return ReceiptLineItem(
            description: description,
            quantity: quantity,
            totalPrice: price,
            unitPrice: price / quantity,
          );
        }
      }
    }

    // Strategy 2: Quantity suffix: "Pizza Margherita x2 9.50"
    match = _quantitySuffixPattern.firstMatch(line);
    if (match != null) {
      var description = match.group(1)!.trim();
      final quantity = int.parse(match.group(2)!);
      final price = _extractPriceFromLine(line);

      if (price != null && price > 0) {
        // Remove price from description using all patterns
        for (final pattern in _pricePatterns) {
          description = description.replaceAll(pattern, '').trim();
        }
        
        description = description.replaceAll(RegExp(r'\s+'), ' ').trim();
        
        if (description.length >= 2) {
          return ReceiptLineItem(
            description: description,
            quantity: quantity,
            totalPrice: price,
            unitPrice: price / quantity,
          );
        }
      }
    }

    // Strategy 3: Standard format: "Pizza Margherita 9.50"
    final price = _extractPriceFromLine(line);
    if (price != null && price > 0) {
      var description = line;
      
      // Remove price from description using all patterns
      for (final pattern in _pricePatterns) {
        description = description.replaceAll(pattern, '').trim();
      }
      
      // Remove common prefixes (article numbers, etc.)
      description = description.replaceAll(RegExp(r'^[\d\-]+\s+'), '');
      
      // Clean up extra whitespace
      description = description.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      // Must have reasonable description length
      if (description.length >= 2 && description.length <= 100) {
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

  /// Extract price from line using multiple patterns
  double? _extractPriceFromLine(String line) {
    // Try each pattern in order
    for (final pattern in _pricePatterns) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        try {
          // Extract euros and cents
          final euros = match.group(1)!.replaceAll(RegExp(r'\s+'), ''); // Remove spaces from thousands
          final cents = match.group(2)!;
          
          final price = double.parse('$euros.$cents');
          
          // Sanity check: price should be reasonable (0.01 to 99999.99)
          if (price >= 0.01 && price < 100000) {
            return price;
          }
        } catch (e) {
          // Continue to next pattern
          continue;
        }
      }
    }
    
    return null;
  }
}
