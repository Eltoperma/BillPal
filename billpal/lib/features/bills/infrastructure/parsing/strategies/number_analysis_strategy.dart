import 'dart:math';

/// Result of analyzing numbers found in a line
class NumberAnalysisResult {
  final List<double> allNumbers;
  final double? mostLikelyTotal;
  final double? mostLikelyUnitPrice;
  final int? mostLikelyQuantity;
  final double confidence;

  const NumberAnalysisResult({
    required this.allNumbers,
    this.mostLikelyTotal,
    this.mostLikelyUnitPrice,
    this.mostLikelyQuantity,
    required this.confidence,
  });
}

/// Strategy for extracting and analyzing ALL numbers from a line
///
/// This strategy:
/// 1. Extracts all numeric values from a line (not just prices)
/// 2. Analyzes relationships between numbers (divisibility, multiples)
/// 3. Determines which numbers are likely quantities, unit prices, or totals
class NumberAnalysisStrategy {
  // Pattern to extract all numbers (integers and decimals)
  static final _numberPattern = RegExp(r'\b(\d+)(?:[.,]\s?(\d{1,2}))?\b');

  /// Extract ALL numbers from a line
  ///
  /// Returns a list of all numeric values found, in order of appearance.
  /// Handles both integers (like quantities) and decimals (like prices).
  List<double> extractAllNumbers(String line) {
    final numbers = <double>[];

    final matches = _numberPattern.allMatches(line);
    for (final match in matches) {
      try {
        final intPart = match.group(1)!;
        final decimalPart = match.group(2);

        if (decimalPart != null && decimalPart.isNotEmpty) {
          // It's a decimal number (likely a price)
          final number = double.parse('$intPart.$decimalPart');
          // Sanity check: reasonable price range
          if (number >= 0.01 && number < 10000) {
            numbers.add(number);
          }
        } else {
          // It's an integer (could be quantity or year in date)
          final number = double.parse(intPart);
          // Only include reasonable integers (not dates like 2023)
          if (number >= 1 && number < 1000) {
            numbers.add(number);
          }
        }
      } catch (e) {
        continue;
      }
    }

    return numbers;
  }

  /// Analyze numbers to determine which are quantities, unit prices, and totals
  ///
  /// Uses multiple heuristics:
  /// 1. Divisibility analysis (total / unit_price = quantity)
  /// 2. Multiplication verification (quantity × unit_price = total)
  /// 3. Positional analysis (largest number is usually the total)
  /// 4. Type analysis (integers are often quantities, decimals are prices)
  NumberAnalysisResult analyzeNumbers(
    String line,
    List<double> numbers, {
    double? receiptTotal,
  }) {
    if (numbers.isEmpty) {
      return const NumberAnalysisResult(allNumbers: [], confidence: 0.0);
    }

    // Special case: only one number
    if (numbers.length == 1) {
      final number = numbers[0];
      // If it's a whole number < 20, likely a quantity
      if (number == number.toInt().toDouble() && number < 20) {
        return NumberAnalysisResult(
          allNumbers: numbers,
          mostLikelyQuantity: number.toInt(),
          confidence: 0.5,
        );
      }
      // Otherwise, likely a price
      return NumberAnalysisResult(
        allNumbers: numbers,
        mostLikelyTotal: number,
        confidence: 0.7,
      );
    }

    // Special case: two numbers
    if (numbers.length == 2) {
      return _analyzeTwoNumbers(numbers[0], numbers[1], line);
    }

    // Three or more numbers - most complex case
    if (numbers.length >= 3) {
      return _analyzeMultipleNumbers(numbers, line);
    }

    return NumberAnalysisResult(allNumbers: numbers, confidence: 0.0);
  }

  /// Analyze case with exactly two numbers
  NumberAnalysisResult _analyzeTwoNumbers(
    double num1,
    double num2,
    String line,
  ) {
    // Check if first number is a small integer (likely quantity)
    final isNum1SmallInt =
        num1 == num1.toInt().toDouble() && num1 >= 1 && num1 <= 20;
    final isNum2SmallInt =
        num2 == num2.toInt().toDouble() && num2 >= 1 && num2 <= 20;

    // Case 1: First is small integer, second is larger (likely quantity × price)
    if (isNum1SmallInt && num2 > num1) {
      final quantity = num1.toInt();
      final unitPrice = num2 / quantity;

      // Check if unit price is reasonable
      if (unitPrice >= 0.5 && unitPrice < 500) {
        return NumberAnalysisResult(
          allNumbers: [num1, num2],
          mostLikelyQuantity: quantity,
          mostLikelyTotal: num2,
          mostLikelyUnitPrice: unitPrice,
          confidence: 0.8,
        );
      }
    }

    // Case 2: Second is small integer (suffix pattern like "Item x2 9.50")
    if (isNum2SmallInt) {
      // Check if there's an "x" or "×" near the second number
      final hasSuffixPattern = RegExp(
        r'[xX×*]\s*${num2.toInt()}\s',
      ).hasMatch(line);
      if (hasSuffixPattern) {
        return NumberAnalysisResult(
          allNumbers: [num1, num2],
          mostLikelyQuantity: num2.toInt(),
          mostLikelyUnitPrice: num1,
          mostLikelyTotal: num1 * num2,
          confidence: 0.7,
        );
      }
    }

    // Case 3: Check divisibility (num2 / num1 gives reasonable quantity)
    if (num2 > num1 && num1 > 0) {
      final ratio = num2 / num1;
      final roundedRatio = ratio.round();

      // If ratio is close to a whole number and reasonable as quantity
      if ((ratio - roundedRatio).abs() < 0.1 &&
          roundedRatio >= 2 &&
          roundedRatio <= 20) {
        return NumberAnalysisResult(
          allNumbers: [num1, num2],
          mostLikelyQuantity: roundedRatio,
          mostLikelyUnitPrice: num1,
          mostLikelyTotal: num2,
          confidence: 0.75,
        );
      }
    }

    // Default: larger number is total
    final larger = max(num1, num2);
    final smaller = min(num1, num2);

    return NumberAnalysisResult(
      allNumbers: [num1, num2],
      mostLikelyTotal: larger,
      mostLikelyUnitPrice: smaller,
      mostLikelyQuantity: 1,
      confidence: 0.6,
    );
  }

  /// Analyze case with three or more numbers
  NumberAnalysisResult _analyzeMultipleNumbers(
    List<double> numbers,
    String line,
  ) {
    // Strategy: Try to find quantity × unit_price = total
    // The largest number is most likely the total

    final sortedNumbers = List<double>.from(numbers)..sort();
    final largest = sortedNumbers.last;

    // Special case: Check for unit size indicator
    final hasVolumeUnit = RegExp(
      r'\b[0-9.,]+\s*[Ll](iter)?\b',
      caseSensitive: false,
    ).hasMatch(line);
    List<double> filteredNumbers = numbers;

    if (hasVolumeUnit) {
      // Filter out small decimals that are likely volume measurements
      filteredNumbers = numbers.where((n) {
        // Keep numbers that are either:
        // - Integers (quantities)
        // - Larger decimals (prices > 2.00)
        // - The largest number (always keep the total)
        return n == n.toInt().toDouble() || n >= 2.0 || n == largest;
      }).toList();

      if (filteredNumbers.length >= 2 &&
          filteredNumbers.length < numbers.length) {
        if (filteredNumbers.length == 2) {
          return _analyzeTwoNumbers(
            filteredNumbers[0],
            filteredNumbers[1],
            line,
          );
        }
      }
    }

    // Try all combinations of remaining numbers (use filtered if available)
    final numbersToAnalyze = filteredNumbers.length >= 2
        ? filteredNumbers
        : numbers;

    for (int i = 0; i < numbersToAnalyze.length - 1; i++) {
      for (int j = i + 1; j < numbersToAnalyze.length; j++) {
        final num1 = numbersToAnalyze[i];
        final num2 = numbersToAnalyze[j];

        // Skip if both are the largest
        if (num1 == largest && num2 == largest) continue;

        // Check if num1 (quantity) × num2 (unit price) = largest (total)
        final product = num1 * num2;
        if ((product - largest).abs() < 0.02) {
          // Found a match!
          final isNum1SmallInt =
              num1 == num1.toInt().toDouble() && num1 >= 1 && num1 <= 20;
          final isNum2SmallInt =
              num2 == num2.toInt().toDouble() && num2 >= 1 && num2 <= 20;

          // Prefer the small integer as quantity
          if (isNum1SmallInt && !isNum2SmallInt) {
            return NumberAnalysisResult(
              allNumbers: numbers,
              mostLikelyQuantity: num1.toInt(),
              mostLikelyUnitPrice: num2,
              mostLikelyTotal: largest,
              confidence: 0.9,
            );
          } else if (isNum2SmallInt && !isNum1SmallInt) {
            return NumberAnalysisResult(
              allNumbers: numbers,
              mostLikelyQuantity: num2.toInt(),
              mostLikelyUnitPrice: num1,
              mostLikelyTotal: largest,
              confidence: 0.9,
            );
          }
        }

        // Check if num1 × num2 equals any other number (not just largest)
        for (final candidate in numbersToAnalyze) {
          if (candidate != num1 && candidate != num2) {
            final product = num1 * num2;
            if ((product - candidate).abs() < 0.02) {
              final isNum1SmallInt =
                  num1 == num1.toInt().toDouble() && num1 >= 1 && num1 <= 20;

              if (isNum1SmallInt) {
                return NumberAnalysisResult(
                  allNumbers: numbers,
                  mostLikelyQuantity: num1.toInt(),
                  mostLikelyUnitPrice: num2,
                  mostLikelyTotal: candidate,
                  confidence: 0.85,
                );
              }
            }
          }
        }
      }
    }

    // No multiplication match found
    // Default: largest is total, first small integer is quantity
    int? quantity;
    double? unitPrice;

    for (final num in numbersToAnalyze) {
      if (num == num.toInt().toDouble() &&
          num >= 1 &&
          num <= 20 &&
          quantity == null) {
        quantity = num.toInt();
        break;
      }
    }

    if (quantity != null && quantity > 1) {
      unitPrice = largest / quantity;
    }

    return NumberAnalysisResult(
      allNumbers: numbers,
      mostLikelyQuantity: quantity,
      mostLikelyUnitPrice: unitPrice,
      mostLikelyTotal: largest,
      confidence: 0.5,
    );
  }

  /// Check if numbers are consistent (do they multiply correctly?)
  bool verifyNumberRelationship({
    required int quantity,
    required double unitPrice,
    required double total,
    double tolerance = 0.02,
  }) {
    final expectedTotal = quantity * unitPrice;
    return (expectedTotal - total).abs() < tolerance;
  }

  /// Find the best combination of items that sum to the receipt total
  ///
  double validateItemsAgainstTotal({
    required List<double> itemTotals,
    required double receiptTotal,
    double tolerance = 0.05,
  }) {
    if (itemTotals.isEmpty) return 0.0;

    final calculatedTotal = itemTotals.fold(0.0, (sum, item) => sum + item);
    final difference = (calculatedTotal - receiptTotal).abs();

    if (difference <= tolerance) {
      return 1.0; // Perfect match
    }

    // Calculate confidence based on percentage difference
    final percentDiff = difference / receiptTotal;

    if (percentDiff < 0.01) return 0.95; // < 1% difference
    if (percentDiff < 0.02) return 0.90; // < 2% difference
    if (percentDiff < 0.05) return 0.80; // < 5% difference
    if (percentDiff < 0.10) return 0.60; // < 10% difference

    return 0.3; // Poor match
  }
}
