/// Konfigurationsbasierter Kategorisierungsservice
/// Unterstützt mehrere Sprachen und ist einfach erweiterbar
class ConfigurableCategoryService {
  static const Map<String, CategoryDefinition> _categories = {
    'restaurant_food': CategoryDefinition(
      id: 'restaurant_food',
      nameDE: 'Restaurant & Essen',
      nameEN: 'Restaurant & Food',
      icon: '🍕',
      keywords: {
        'de': [
          'restaurant', 'pizza', 'döner', 'kebab', 'burger', 'mcdonalds', 'kfc',
          'sushi', 'café', 'coffee', 'starbucks', 'bar', 'essen', 'food',
          'mittagessen', 'abendessen', 'bäcker', 'imbiss', 'lieferando',
          'getränk', 'bier', 'wein'
        ],
        'en': [
          'restaurant', 'pizza', 'burger', 'mcdonalds', 'kfc', 'subway',
          'sushi', 'cafe', 'coffee', 'starbucks', 'bar', 'food', 'meal',
          'lunch', 'dinner', 'breakfast', 'bakery', 'delivery', 'drink',
          'beer', 'wine'
        ],
      },
      priority: 10,
    ),
    
    'entertainment': CategoryDefinition(
      id: 'entertainment',
      nameDE: 'Unterhaltung',
      nameEN: 'Entertainment',
      icon: '🎬',
      keywords: {
        'de': [
          'kino', 'bowling', 'party', 'club', 'disco', 'konzert', 'theater',
          'museum', 'zoo', 'park', 'festival', 'netflix', 'spotify', 'spiel'
        ],
        'en': [
          'cinema', 'movie', 'bowling', 'party', 'club', 'disco', 'concert',
          'theater', 'museum', 'zoo', 'park', 'festival', 'netflix', 'spotify', 'game'
        ],
      },
      priority: 8,
    ),
    
    'transport': CategoryDefinition(
      id: 'transport',
      nameDE: 'Transport',
      nameEN: 'Transport',
      icon: '🚗',
      keywords: {
        'de': [
          'tankstelle', 'tanken', 'benzin', 'diesel', 'uber', 'taxi', 'bolt',
          'bus', 'bahn', 'zug', 'ticket', 'parken', 'maut', 'auto'
        ],
        'en': [
          'gas', 'station', 'fuel', 'gasoline', 'uber', 'taxi', 'bolt',
          'bus', 'train', 'ticket', 'parking', 'toll', 'car'
        ],
      },
      priority: 7,
    ),
    
    'shopping': CategoryDefinition(
      id: 'shopping',
      nameDE: 'Einkaufen',
      nameEN: 'Shopping',
      icon: '🛒',
      keywords: {
        'de': [
          'supermarkt', 'einkauf', 'shopping', 'rewe', 'edeka', 'aldi', 'lidl',
          'amazon', 'zalando', 'ikea', 'drogerie', 'apotheke'
        ],
        'en': [
          'supermarket', 'shopping', 'store', 'grocery', 'amazon', 'walmart',
          'target', 'ikea', 'pharmacy', 'drugstore'
        ],
      },
      priority: 6,
    ),
    
    'housing': CategoryDefinition(
      id: 'housing',
      nameDE: 'Wohnen & Fixkosten',
      nameEN: 'Housing & Fixed Costs',
      icon: '🏠',
      keywords: {
        'de': [
          'miete', 'nebenkosten', 'strom', 'gas', 'wasser', 'internet',
          'handy', 'versicherung', 'bank', 'gebühr'
        ],
        'en': [
          'rent', 'utilities', 'electricity', 'gas', 'water', 'internet',
          'phone', 'insurance', 'bank', 'fee'
        ],
      },
      priority: 9,
    ),
  };

  /// Kategorisiert einen Titel basierend auf Konfiguration
  static String categorizeTitle(String title, {String locale = 'en'}) {
    print('🏷️ CategoryService: Categorizing "$title" with locale "$locale"');
    final lowerTitle = title.toLowerCase();
    final Map<String, double> categoryScores = {};

    // Alle Kategorien durchgehen und Scores berechnen
    for (final category in _categories.values) {
      final keywords = category.keywords[locale] ?? category.keywords['en'] ?? [];
      double score = 0.0;

      for (final keyword in keywords) {
        final lowerKeyword = keyword.toLowerCase();
        
        if (lowerTitle.contains(lowerKeyword)) {
          // Basis-Score
          double matchScore = 1.0;
          
          // Bonus für exakte Matches
          if (lowerTitle == lowerKeyword) {
            matchScore += 2.0;
          }
          
          // Bonus für Wort-Anfang
          if (lowerTitle.startsWith(lowerKeyword)) {
            matchScore += 1.0;
          }
          
          // Bonus für längere Keywords (spezifischer)
          if (lowerKeyword.length > 4) {
            matchScore += 0.5;
          }
          
          // Kategorie-Priorität einbeziehen
          matchScore *= (category.priority / 10.0);
          
          score += matchScore;
        }
      }
      
      if (score > 0) {
        categoryScores[category.id] = score;
      }
    }

    // Beste Kategorie zurückgeben
    if (categoryScores.isNotEmpty) {
      final bestCategoryId = categoryScores.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      final category = _categories[bestCategoryId]!;
      final result = locale == 'de' ? category.nameDE : category.nameEN;
      print('🏷️ CategoryService: Result for "$title" → "$result" (locale: $locale)');
      return result;
    }

    // Fallback
    final fallback = locale == 'de' ? 'Sonstiges' : 'Other';
    print('🏷️ CategoryService: No match for "$title", using fallback "$fallback" (locale: $locale)');
    return fallback;
  }

  /// Alle verfügbaren Kategorien abrufen
  static List<CategoryDefinition> getAllCategories() {
    return _categories.values.toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Kategorie-Details abrufen
  static CategoryDefinition? getCategoryById(String id) {
    return _categories[id];
  }

  /// Debug-Info für eine Kategorisierung
  static CategoryAnalysis analyzeTitle(String title, {String locale = 'de'}) {
    final lowerTitle = title.toLowerCase();
    final Map<String, CategoryScore> categoryScores = {};

    for (final category in _categories.values) {
      final keywords = category.keywords[locale] ?? category.keywords['en'] ?? [];
      final matchedKeywords = <String>[];
      double score = 0.0;

      for (final keyword in keywords) {
        if (lowerTitle.contains(keyword.toLowerCase())) {
          matchedKeywords.add(keyword);
          score += 1.0;
        }
      }

      if (matchedKeywords.isNotEmpty) {
        categoryScores[category.id] = CategoryScore(
          category: category,
          score: score,
          matchedKeywords: matchedKeywords,
        );
      }
    }

    final bestMatch = categoryScores.values.isEmpty 
        ? null 
        : categoryScores.values.reduce((a, b) => a.score > b.score ? a : b);

    return CategoryAnalysis(
      title: title,
      bestMatch: bestMatch,
      allMatches: categoryScores.values.toList()
        ..sort((a, b) => b.score.compareTo(a.score)),
    );
  }
}

/// Definition einer Kategorie
class CategoryDefinition {
  final String id;
  final String nameDE;
  final String nameEN;
  final String icon;
  final Map<String, List<String>> keywords;
  final int priority; // 1-10, höher = wichtiger

  const CategoryDefinition({
    required this.id,
    required this.nameDE,
    required this.nameEN,
    required this.icon,
    required this.keywords,
    required this.priority,
  });
}

/// Score für eine Kategorie-Analyse
class CategoryScore {
  final CategoryDefinition category;
  final double score;
  final List<String> matchedKeywords;

  const CategoryScore({
    required this.category,
    required this.score,
    required this.matchedKeywords,
  });
}

/// Analyse-Result für Debugging
class CategoryAnalysis {
  final String title;
  final CategoryScore? bestMatch;
  final List<CategoryScore> allMatches;

  const CategoryAnalysis({
    required this.title,
    required this.bestMatch,
    required this.allMatches,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Kategorie-Analyse für: "$title"');
    
    if (bestMatch != null) {
      buffer.writeln('Beste Übereinstimmung: ${bestMatch!.category.nameDE} (Score: ${bestMatch!.score})');
      buffer.writeln('Gefundene Keywords: ${bestMatch!.matchedKeywords.join(', ')}');
    } else {
      buffer.writeln('Keine Übereinstimmung gefunden');
    }
    
    if (allMatches.length > 1) {
      buffer.writeln('\nAlle Übereinstimmungen:');
      for (final match in allMatches) {
        buffer.writeln('- ${match.category.nameDE}: ${match.score} (${match.matchedKeywords.join(', ')})');
      }
    }
    
    return buffer.toString();
  }
}