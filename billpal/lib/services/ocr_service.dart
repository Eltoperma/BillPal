import 'dart:math';
import 'package:billpal/models/financial_data.dart';

/// Service für OCR-Funktionalität (Mock-Implementation)
class OCRService {
  static final OCRService _instance = OCRService._internal();
  factory OCRService() => _instance;
  OCRService._internal();

  final Random _random = Random();

  /// Simuliert OCR-Erkennung einer Rechnung
  Future<OCRResult> recognizeReceipt(String imagePath) async {
    // Simuliere Verarbeitungszeit
    await Future.delayed(Duration(milliseconds: 1500 + _random.nextInt(1000)));
    
    // Zufällige Demo-Daten für verschiedene Geschäfte
    final merchants = [
      'REWE',
      'EDEKA',
      'Restaurant "Zur Sonne"',
      'McDonald\'s',
      'Tankstelle Aral',
      'Café Central',
      'Pizza Express',
      'Bowling Palace',
    ];

    final merchant = merchants[_random.nextInt(merchants.length)];
    final confidence = 0.7 + _random.nextDouble() * 0.3; // 70-100%
    
    return OCRResult(
      merchantName: merchant,
      totalAmount: _generateRealisticTotal(merchant),
      date: DateTime.now().subtract(Duration(days: _random.nextInt(7))),
      items: _generateItemsForMerchant(merchant),
      confidence: confidence,
    );
  }

  double _generateRealisticTotal(String merchant) {
    switch (merchant) {
      case 'REWE':
      case 'EDEKA':
        return 15.0 + _random.nextDouble() * 50.0; // 15-65€
      case 'McDonald\'s':
        return 8.0 + _random.nextDouble() * 20.0; // 8-28€
      case 'Tankstelle Aral':
        return 30.0 + _random.nextDouble() * 70.0; // 30-100€
      case 'Pizza Express':
        return 20.0 + _random.nextDouble() * 40.0; // 20-60€
      case 'Bowling Palace':
        return 25.0 + _random.nextDouble() * 50.0; // 25-75€
      default:
        return 10.0 + _random.nextDouble() * 60.0; // 10-70€
    }
  }

  List<OCRItem> _generateItemsForMerchant(String merchant) {
    switch (merchant) {
      case 'REWE':
      case 'EDEKA':
        return [
          const OCRItem(name: 'Milch 1,5%', amount: 1.19, quantity: 1),
          const OCRItem(name: 'Brot Vollkorn', amount: 2.49, quantity: 1),
          const OCRItem(name: 'Bananen', amount: 1.89, quantity: 1),
          const OCRItem(name: 'Joghurt 4er Pack', amount: 2.99, quantity: 1),
        ];
      
      case 'McDonald\'s':
        return [
          const OCRItem(name: 'Big Mac Menu', amount: 8.49, quantity: 1),
          const OCRItem(name: 'Chicken McNuggets', amount: 4.99, quantity: 1),
          const OCRItem(name: 'Coca Cola 0,5L', amount: 2.49, quantity: 2),
        ];
      
      case 'Pizza Express':
        return [
          const OCRItem(name: 'Pizza Margherita', amount: 8.50, quantity: 1),
          const OCRItem(name: 'Pizza Salami', amount: 9.50, quantity: 1),
          const OCRItem(name: 'Liefergebühr', amount: 2.50, quantity: 1),
        ];
      
      case 'Bowling Palace':
        return [
          const OCRItem(name: 'Bowling 2 Bahnen', amount: 24.00, quantity: 1),
          const OCRItem(name: 'Getränke', amount: 12.50, quantity: 1),
          const OCRItem(name: 'Snacks', amount: 8.00, quantity: 1),
        ];
      
      default:
        return [
          OCRItem(name: 'Artikel 1', amount: _random.nextDouble() * 20.0),
          OCRItem(name: 'Artikel 2', amount: _random.nextDouble() * 15.0),
        ];
    }
  }

  /// Simuliert QR-Code Scan einer Rechnung
  Future<String?> scanQRCode() async {
    // Simuliere Scan-Zeit
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Simuliere zufällig erfolgreichen oder fehlgeschlagenen Scan
    if (_random.nextDouble() > 0.2) { // 80% Erfolgsrate
      return 'BILL_QR_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      return null; // Scan fehlgeschlagen
    }
  }

  /// Verarbeitet QR-Code zu Rechnungsdaten
  Future<Map<String, dynamic>?> processQRCode(String qrCode) async {
    // Simuliere Verarbeitungszeit
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock-Daten basierend auf QR-Code
    return {
      'merchant': 'Restaurant Via QR',
      'total': 42.50,
      'date': DateTime.now().toIso8601String(),
      'items': [
        {'name': 'Hauptgericht', 'amount': 28.50},
        {'name': 'Getränk', 'amount': 4.50},
        {'name': 'Dessert', 'amount': 9.50},
      ],
    };
  }
}
