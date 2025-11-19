// import 'package:tflite_flutter/tflite_flutter.dart'; // TODO: Add when TensorFlow Lite is needed

/// Modernerer ML-basierter Kategorisierungsservice
class MLCategoryService {
  static const Map<String, String> _categoryMappings = {
    'restaurant_food': 'Restaurant & Essen',
    'entertainment': 'Unterhaltung',
    'transport': 'Transport',
    'shopping': 'Einkaufen',
    'housing': 'Wohnen & Fixkosten',
    'other': 'Sonstiges',
  };

  // Mehrsprachige Keywords für Fallback
  static const Map<String, List<String>> _multilingualKeywords = {
    'restaurant_food': [
      // Deutsch
      'restaurant', 'pizza', 'döner', 'essen', 'café', 'bar', 'bäcker',
      // English
      'restaurant', 'food', 'meal', 'lunch', 'dinner', 'cafe', 'bar',
      // Französisch (optional)
      'restaurant', 'nourriture', 'repas',
    ],
    'entertainment': [
      // Deutsch
      'kino', 'bowling', 'party', 'konzert', 'theater', 'netflix',
      // English
      'cinema', 'movie', 'bowling', 'party', 'concert', 'theater', 'netflix',
    ],
    'transport': [
      // Deutsch
      'tankstelle', 'uber', 'taxi', 'bus', 'bahn', 'parken',
      // English
      'gas', 'station', 'uber', 'taxi', 'bus', 'train', 'parking',
    ],
    'shopping': [
      // Deutsch
      'supermarkt', 'einkauf', 'shopping', 'amazon', 'zalando',
      // English
      'supermarket', 'shopping', 'store', 'amazon', 'mall',
    ],
    'housing': [
      // Deutsch
      'miete', 'strom', 'gas', 'internet', 'versicherung',
      // English
      'rent', 'electricity', 'gas', 'internet', 'insurance',
    ],
  };

  // Interpreter? _interpreter; // TODO: Uncomment when TensorFlow Lite is added
  dynamic _interpreter;
  bool _isModelLoaded = false;

  /// Initialisiert das ML-Modell
  Future<void> initialize() async {
    try {
      // Hier würdest du ein vortrainiertes Modell laden
      // _interpreter = await Interpreter.fromAsset('models/category_classifier.tflite');
      _isModelLoaded = true;
    } catch (e) {
      print('Fehler beim Laden des ML-Modells: $e');
      _isModelLoaded = false;
    }
  }

  /// Kategorisiert einen Rechnungstitel mit ML + Fallback
  Future<String> categorizeTitle(String title, {String locale = 'de'}) async {
    // Erste Option: ML-Modell (wenn verfügbar)
    if (_isModelLoaded && _interpreter != null) {
      try {
        final prediction = await _predictWithModel(title);
        if (prediction != null) {
          return _categoryMappings[prediction] ?? 'Sonstiges';
        }
      } catch (e) {
        print('ML-Prediction fehlgeschlagen: $e');
      }
    }

    // Fallback: Intelligentere Keyword-Suche
    return _categorizeWithKeywords(title.toLowerCase());
  }

  /// ML-Vorhersage (Placeholder für echtes Modell)
  Future<String?> _predictWithModel(String title) async {
    // Hier würdest du:
    // 1. Text zu Tensor konvertieren
    // 2. Durch das Modell laufen lassen
    // 3. Prediction zurückgeben
    
    // Placeholder Implementation
    await Future.delayed(const Duration(milliseconds: 10));
    return null; // Für jetzt deaktiviert
  }

  /// Verbesserte Keyword-basierte Kategorisierung
  String _categorizeWithKeywords(String lowerTitle) {
    // Scoring-System: Kategorien bekommen Punkte basierend auf Matches
    final Map<String, double> categoryScores = {};

    for (final entry in _multilingualKeywords.entries) {
      final category = entry.key;
      final keywords = entry.value;
      
      double score = 0.0;
      for (final keyword in keywords) {
        if (lowerTitle.contains(keyword.toLowerCase())) {
          // Gewichtung basierend auf Keyword-Länge und Position
          final weight = keyword.length > 3 ? 2.0 : 1.0;
          final positionBonus = lowerTitle.startsWith(keyword.toLowerCase()) ? 0.5 : 0.0;
          score += weight + positionBonus;
        }
      }
      
      if (score > 0) {
        categoryScores[category] = score;
      }
    }

    // Höchste Punktzahl gewinnt
    if (categoryScores.isNotEmpty) {
      final bestCategory = categoryScores.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      return _categoryMappings[bestCategory] ?? 'Sonstiges';
    }

    return 'Sonstiges';
  }

  /// Dispose-Methode für Cleanup
  void dispose() {
    // _interpreter?.close(); // TODO: Uncomment when TensorFlow Lite is added
  }
}