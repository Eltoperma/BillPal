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

