import 'package:flutter/material.dart';
import 'package:billpal/shared/application/services/configurable_category_service.dart';
import 'package:billpal/core/database/repositories/user_category_repository.dart';
import 'package:billpal/shared/application/services/user_service.dart';
import 'package:billpal/core/logging/app_logger.dart';

/// Service für die Locale-Context-Erkennung
/// Vorbereitet für zukünftige Internationalisierung ohne breaking changes
class CategoryLocaleService {
  /// Ermittelt die aktuelle Sprache aus verschiedenen Quellen
  /// Fallback-Chain: LocaleController -> Scaffold -> MaterialApp -> System -> 'de'
  static String getCurrentLocale(BuildContext? context) {
    // Future: Hier wird später der LocaleController/l10n integriert
    // Für jetzt: Verwende einfache Context-basierte Erkennung
    
    if (context != null) {
      try {
        final locale = Localizations.localeOf(context);
        final languageCode = locale.languageCode.toLowerCase();
        
        // Unterstützte Sprachen prüfen
        if (['de', 'en'].contains(languageCode)) {
          return languageCode;
        }
      } catch (e) {
        // Fallback falls Localization nicht verfügbar
      }
    }
    
    // Fallback: Deutsch als Standard
    return 'de';
  }

  /// Holt den lokalisierten Namen einer Kategorie
  static String getCategoryName(CategoryDefinition category, String locale) {
    switch (locale.toLowerCase()) {
      case 'en':
        return category.nameEN;
      case 'de':
      default:
        return category.nameDE;
    }
  }

  /// Holt den lokalisierten Namen für "Sonstiges"
  static String getOtherCategoryName(String locale) {
    switch (locale.toLowerCase()) {
      case 'en':
        return 'Other';
      case 'de':
      default:
        return 'Sonstiges';
    }
  }
}

/// User-Korrektur Datenmodell
class UserCategoryCorrection {
  final String id;
  final String billTitle;
  final String originalCategory;
  final String correctedCategory;
  final String locale;
  final DateTime timestamp;

  UserCategoryCorrection({
    required this.id,
    required this.billTitle,
    required this.originalCategory,
    required this.correctedCategory,
    required this.locale,
    required this.timestamp,
  });
}

/// Erweiterte Kategorie-Service mit User-Learning und SQLite-Persistierung
class MultiLanguageUserCategoryService extends ConfigurableCategoryService {
  final UserCategoryRepository _repository = UserCategoryRepository();
  final UserService _userService = UserService();
  
  // Cache für Performance (wird aus DB geladen)
  final Map<String, Map<String, List<String>>> _userKeywordsCache = {};
  final List<UserCategoryCorrection> _userCorrectionsCache = [];

  /// Lädt User-Keywords aus der Datenbank für bessere Performance
  Future<void> loadUserKeywords(String locale) async {
    try {
      final currentUser = await _userService.getCurrentUser();
      final userId = int.tryParse(currentUser.id) ?? 1;
      
      _userKeywordsCache.clear();
      
      for (final category in ConfigurableCategoryService.getAllCategories()) {
        final keywords = await _repository.getUserKeywords(
          userId: userId,
          categoryId: category.id,
          locale: locale,
        );
        
        if (keywords.isNotEmpty) {
          _userKeywordsCache[category.id] ??= {};
          _userKeywordsCache[category.id]![locale] = keywords;
        }
      }
      
      AppLogger.sql.success('User-Keywords für Locale "$locale" geladen: ${_userKeywordsCache.keys.length} Kategorien');
    } catch (e) {
      AppLogger.sql.error('Fehler beim Laden der User-Keywords: $e');
    }
  }

  /// Fügt ein User-Keyword in einer bestimmten Sprache hinzu
  Future<void> addUserKeyword(String categoryId, String keyword, String locale) async {
    final keywordLower = keyword.toLowerCase().trim();
    
    // Leere Keywords ignorieren
    if (keywordLower.isEmpty) return;
    
    try {
      final currentUser = await _userService.getCurrentUser();
      final userId = int.tryParse(currentUser.id) ?? 1;
      
      await _repository.insertUserKeyword(
        userId: userId,
        categoryId: categoryId,
        keyword: keywordLower,
        locale: locale,
      );
      
      // Cache aktualisieren
      _userKeywordsCache[categoryId] ??= {};
      _userKeywordsCache[categoryId]![locale] ??= [];
      if (!_userKeywordsCache[categoryId]![locale]!.contains(keywordLower)) {
        _userKeywordsCache[categoryId]![locale]!.add(keywordLower);
      }
      
      AppLogger.sql.success('User-Keyword "$keywordLower" für Kategorie $categoryId hinzugefügt');
    } catch (e) {
      AppLogger.sql.error('Fehler beim Hinzufügen des Keywords: $e');
    }
  }

  /// Entfernt ein User-Keyword in einer bestimmten Sprache
  Future<void> removeUserKeyword(String categoryId, String keyword, String locale) async {
    try {
      final currentUser = await _userService.getCurrentUser();
      final userId = int.tryParse(currentUser.id) ?? 1;
      
      await _repository.removeUserKeyword(
        userId: userId,
        categoryId: categoryId,
        keyword: keyword.toLowerCase().trim(),
        locale: locale,
      );
      
      // Cache aktualisieren
      _userKeywordsCache[categoryId]?[locale]?.remove(keyword.toLowerCase().trim());
      
      AppLogger.sql.success('User-Keyword "$keyword" für Kategorie $categoryId entfernt');
    } catch (e) {
      AppLogger.sql.error('Fehler beim Entfernen des Keywords: $e');
    }
  }

  /// Holt alle User-Keywords für eine Kategorie in einer bestimmten Sprache
  List<String> getUserKeywords(String categoryId, String locale) {
    return _userKeywordsCache[categoryId]?[locale] ?? [];
  }

  /// Lädt User-Korrekturen aus der Datenbank
  Future<void> loadUserCorrections() async {
    try {
      final currentUser = await _userService.getCurrentUser();
      final userId = int.tryParse(currentUser.id) ?? 1;
      
      final rawCorrections = await _repository.getUserCorrections(userId: userId);
      
      _userCorrectionsCache.clear();
      for (final raw in rawCorrections) {
        _userCorrectionsCache.add(UserCategoryCorrection(
          id: raw['id'].toString(),
          billTitle: raw['bill_title'],
          originalCategory: raw['original_category'],
          correctedCategory: raw['corrected_category'],
          locale: raw['locale'],
          timestamp: DateTime.parse(raw['created_at']),
        ));
      }
      
      AppLogger.sql.success('${_userCorrectionsCache.length} User-Korrekturen geladen');
    } catch (e) {
      AppLogger.sql.error('Fehler beim Laden der User-Korrekturen: $e');
    }
  }

  /// Speichert eine User-Korrektur mit Sprach-Context
  Future<void> addCorrection(
    String billTitle,
    String originalCategory,
    String correctedCategory,
    String locale,
  ) async {
    try {
      final currentUser = await _userService.getCurrentUser();
      final userId = int.tryParse(currentUser.id) ?? 1;
      
      final correctionId = await _repository.insertUserCorrection(
        userId: userId,
        billTitle: billTitle,
        originalCategory: originalCategory,
        correctedCategory: correctedCategory,
        locale: locale,
      );
      
      // Cache aktualisieren
      _userCorrectionsCache.add(UserCategoryCorrection(
        id: correctionId.toString(),
        billTitle: billTitle,
        originalCategory: originalCategory,
        correctedCategory: correctedCategory,
        locale: locale,
        timestamp: DateTime.now(),
      ));
      
      AppLogger.sql.success('User-Korrektur hinzugefügt: "$originalCategory" → "$correctedCategory"');
    } catch (e) {
      AppLogger.sql.error('Fehler beim Hinzufügen der Korrektur: $e');
    }
  }

  /// Holt alle User-Korrekturen
  Future<List<UserCategoryCorrection>> getAllCorrections() async {
    if (_userCorrectionsCache.isEmpty) {
      await loadUserCorrections();
    }
    return List.from(_userCorrectionsCache);
  }

  /// Entfernt eine User-Korrektur
  Future<void> removeCorrection(String correctionId) async {
    try {
      await _repository.removeUserCorrection(correctionId: int.parse(correctionId));
      
      // Cache aktualisieren
      _userCorrectionsCache.removeWhere((c) => c.id == correctionId);
      
      AppLogger.sql.success('User-Korrektur $correctionId entfernt');
    } catch (e) {
      AppLogger.sql.error('Fehler beim Entfernen der Korrektur: $e');
    }
  }

  /// Erweiterte Kategorisierung mit User-Keywords
  String categorizeWithUserKeywords(String title, {String locale = 'de'}) {
    // Erst User-Keywords prüfen (höhere Priorität)
    for (final category in ConfigurableCategoryService.getAllCategories()) {
      final userKeywords = getUserKeywords(category.id, locale);
      for (final keyword in userKeywords) {
        if (title.toLowerCase().contains(keyword.toLowerCase())) {
          return CategoryLocaleService.getCategoryName(category, locale);
        }
      }
    }
    
    // Dann Standard-Kategorisierung
    final standardResult = ConfigurableCategoryService.categorizeTitle(title);
    
    return standardResult;
  }
}