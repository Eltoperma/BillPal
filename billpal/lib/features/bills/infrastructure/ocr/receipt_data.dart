class ReceiptData {
  final String? restaurantName;
  final List<ReceiptLineItem> items;
  final double? total;
  final String rawText;

  const ReceiptData({
    this.restaurantName,
    required this.items,
    this.total,
    required this.rawText,
  });

  bool get hasData =>
      restaurantName != null || items.isNotEmpty || total != null;

  double get calculatedTotal =>
      items.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0.0));

  bool get isTotalConsistent {
    if (total == null || items.isEmpty) return true;
    final diff = (total! - calculatedTotal).abs();
    return diff < 0.05;
  }

  /// Expand items with quantity > 1 into individual items
  ///
  /// For example, "2x Pizza 9.50" becomes two separate items:
  /// - "Pizza 4.75"
  /// - "Pizza 4.75"
  ///
  /// This is useful for forms where each item should be assigned individually.
  List<ReceiptLineItem> get expandedItems {
    final expanded = <ReceiptLineItem>[];
    
    for (final item in items) {
      if (item.quantity > 1 && item.unitPrice != null) {
        // Expand into individual items
        for (int i = 0; i < item.quantity; i++) {
          expanded.add(ReceiptLineItem(
            description: item.description,
            quantity: 1,
            unitPrice: item.unitPrice,
            totalPrice: item.unitPrice,
          ));
        }
      } else {
        // Keep as is
        expanded.add(item);
      }
    }
    
    return expanded;
  }

  /// Get the best subset of items that matches the receipt total
  ///
  /// If items don't sum to the total, this tries to find which items
  /// to keep/remove to match the total. Uses a greedy approach with
  /// subset sum optimization.
  ///
  /// Returns:
  /// - Original items if total matches or no total available
  /// - Best matching subset if a better match is found
  /// - Original items if no better subset exists
  List<ReceiptLineItem> getItemsMatchingTotal({
    bool expandQuantities = true,
    double tolerance = 0.05,
  }) {
    // No total to match against
    if (total == null || items.isEmpty) {
      return expandQuantities ? expandedItems : items;
    }
    
    // Items already match the total
    if (isTotalConsistent) {
      return expandQuantities ? expandedItems : items;
    }
    
    // Try to find best subset
    final itemsToAnalyze = expandQuantities ? expandedItems : items;
    final subset = _findBestSubset(itemsToAnalyze, total!, tolerance);
    
    // If we found a better match, use it; otherwise return all items
    if (subset != null) {
      return subset;
    }
    
    // No better subset found - return all items
    return itemsToAnalyze;
  }

  /// Find the best subset of items that sums closest to the target
  ///
  /// Uses a greedy approach with dynamic programming optimization.
  /// Returns null if no subset is better than including all items.
  List<ReceiptLineItem>? _findBestSubset(
    List<ReceiptLineItem> items,
    double target,
    double tolerance,
  ) {
    // Calculate current difference
    final currentSum = items.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0.0));
    final currentDiff = (currentSum - target).abs();
    
    // Already within tolerance
    if (currentDiff <= tolerance) {
      return null;
    }
    
    // Try removing items one by one (greedy approach)
    // Start by trying to remove items that would bring us closer to target
    List<ReceiptLineItem>? bestSubset;
    double bestDiff = currentDiff;
    
    // If we have too many items, try combinations
    if (items.length <= 15) {
      // Brute force for small sets
      bestSubset = _bruteForceSubset(items, target, tolerance);
      if (bestSubset != null) {
        final subsetSum = bestSubset.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0.0));
        bestDiff = (subsetSum - target).abs();
      }
    } else {
      // Greedy approach for larger sets
      bestSubset = _greedySubset(items, target);
      if (bestSubset != null) {
        final subsetSum = bestSubset.fold(0.0, (sum, item) => sum + (item.totalPrice ?? 0.0));
        bestDiff = (subsetSum - target).abs();
      }
    }
    
    // Return subset only if it's better than current
    if (bestDiff < currentDiff) {
      return bestSubset;
    }
    
    return null;
  }

  /// Brute force subset sum for small item sets (≤ 15 items)
  List<ReceiptLineItem>? _bruteForceSubset(
    List<ReceiptLineItem> items,
    double target,
    double tolerance,
  ) {
    List<ReceiptLineItem>? bestSubset;
    double bestDiff = double.infinity;
    
    // Try all possible subsets (2^n combinations)
    final n = items.length;
    for (int mask = 1; mask < (1 << n); mask++) {
      final subset = <ReceiptLineItem>[];
      double sum = 0.0;
      
      for (int i = 0; i < n; i++) {
        if (mask & (1 << i) != 0) {
          subset.add(items[i]);
          sum += items[i].totalPrice ?? 0.0;
        }
      }
      
      final diff = (sum - target).abs();
      
      // Perfect match within tolerance
      if (diff <= tolerance) {
        return subset;
      }
      
      // Better match
      if (diff < bestDiff) {
        bestDiff = diff;
        bestSubset = subset;
      }
    }
    
    return bestSubset;
  }

  /// Greedy subset approach for large item sets
  List<ReceiptLineItem>? _greedySubset(
    List<ReceiptLineItem> items,
    double target,
  ) {
    // Sort items by price
    final sortedItems = List<ReceiptLineItem>.from(items)
      ..sort((a, b) => (b.totalPrice ?? 0.0).compareTo(a.totalPrice ?? 0.0));
    
    // Try to build subset that sums closest to target
    final subset = <ReceiptLineItem>[];
    double sum = 0.0;
    
    for (final item in sortedItems) {
      final itemPrice = item.totalPrice ?? 0.0;
      
      // Add item if it brings us closer to target
      if ((sum + itemPrice - target).abs() < (sum - target).abs()) {
        subset.add(item);
        sum += itemPrice;
      }
    }
    
    return subset.isEmpty ? null : subset;
  }

  /// Convert to JSON for debugging and serialization
  Map<String, dynamic> toJson() => {
    'restaurantName': restaurantName,
    'total': total,
    'calculatedTotal': calculatedTotal,
    'isTotalConsistent': isTotalConsistent,
    'itemCount': items.length,
    'items': items.map((item) => item.toJson()).toList(),
    'rawText': rawText,
  };

  @override
  String toString() =>
      'ReceiptData('
      'restaurant: $restaurantName, '
      'items: ${items.length}, '
      'total: $total'
      ')';
}

class ReceiptLineItem {
  final String description;
  final double? unitPrice;
  final int quantity;
  final double? totalPrice;

  const ReceiptLineItem({
    required this.description,
    this.unitPrice,
    this.quantity = 1,
    this.totalPrice,
  });

  /// Convert to JSON for debugging and serialization
  Map<String, dynamic> toJson() => {
    'description': description,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalPrice': totalPrice,
  };

  @override
  String toString() =>
      'ReceiptLineItem('
      'description: $description, '
      'quantity: $quantity, '
      'price: $totalPrice'
      ')';
}

