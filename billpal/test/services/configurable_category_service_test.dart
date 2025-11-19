import 'package:flutter_test/flutter_test.dart';
import 'package:billpal/shared/application/services/configurable_category_service.dart';

void main() {
  group('ConfigurableCategoryService Tests', () {
    test('Kategorisiert deutsche Begriffe korrekt', () {
      expect(
        ConfigurableCategoryService.categorizeTitle('Pizza Lieferando'),
        equals('Restaurant & Essen'),
      );
      
      expect(
        ConfigurableCategoryService.categorizeTitle('Kinokarte Avengers'),
        equals('Unterhaltung'),
      );
      
      expect(
        ConfigurableCategoryService.categorizeTitle('Uber Fahrt'),
        equals('Transport'),
      );
      
      expect(
        ConfigurableCategoryService.categorizeTitle('REWE Einkauf'),
        equals('Einkaufen'),
      );
      
      expect(
        ConfigurableCategoryService.categorizeTitle('Miete Januar'),
        equals('Wohnen & Fixkosten'),
      );
    });

    test('Kategorisiert englische Begriffe korrekt', () {
      expect(
        ConfigurableCategoryService.categorizeTitle('Pizza delivery', locale: 'en'),
        equals('Restaurant & Food'),
      );
      
      expect(
        ConfigurableCategoryService.categorizeTitle('Movie ticket', locale: 'en'),
        equals('Entertainment'),
      );
      
      expect(
        ConfigurableCategoryService.categorizeTitle('Gas station', locale: 'en'),
        equals('Transport'),
      );
      
      expect(
        ConfigurableCategoryService.categorizeTitle('Walmart shopping', locale: 'en'),
        equals('Shopping'),
      );
      
      expect(
        ConfigurableCategoryService.categorizeTitle('Rent payment', locale: 'en'),
        equals('Housing & Fixed Costs'),
      );
    });

    test('Fallback funktioniert für unbekannte Begriffe', () {
      expect(
        ConfigurableCategoryService.categorizeTitle('Unbekannter Begriff'),
        equals('Sonstiges'),
      );
      
      expect(
        ConfigurableCategoryService.categorizeTitle('Unknown term', locale: 'en'),
        equals('Other'),
      );
    });

    test('Analyse-Funktion liefert detaillierte Ergebnisse', () {
      final analysis = ConfigurableCategoryService.analyzeTitle('Pizza Restaurant');
      
      expect(analysis.title, equals('Pizza Restaurant'));
      expect(analysis.bestMatch, isNotNull);
      expect(analysis.bestMatch!.category.nameDE, equals('Restaurant & Essen'));
      expect(analysis.bestMatch!.matchedKeywords, contains('pizza'));
      expect(analysis.bestMatch!.matchedKeywords, contains('restaurant'));
    });

    test('Scoring bevorzugt spezifischere Matches', () {
      // "Pizza" sollte eindeutig Restaurant sein, auch wenn "ticket" 
      // sowohl Transport als auch Entertainment matchen könnte
      expect(
        ConfigurableCategoryService.categorizeTitle('Pizza Ticket'),
        equals('Restaurant & Essen'),
      );
    });

    test('Case-insensitive Matching funktioniert', () {
      expect(
        ConfigurableCategoryService.categorizeTitle('PIZZA'),
        equals('Restaurant & Essen'),
      );
      
      expect(
        ConfigurableCategoryService.categorizeTitle('uber'),
        equals('Transport'),
      );
      
      expect(
        ConfigurableCategoryService.categorizeTitle('NetFlix'),
        equals('Unterhaltung'),
      );
    });

    test('Alle Kategorien können abgerufen werden', () {
      final categories = ConfigurableCategoryService.getAllCategories();
      
      expect(categories.length, greaterThan(0));
      expect(categories.first.priority, greaterThanOrEqualTo(categories.last.priority));
      
      // Prüfe dass wichtige Kategorien vorhanden sind
      final categoryNames = categories.map((c) => c.nameDE).toList();
      expect(categoryNames, contains('Restaurant & Essen'));
      expect(categoryNames, contains('Transport'));
      expect(categoryNames, contains('Unterhaltung'));
    });
  });
}