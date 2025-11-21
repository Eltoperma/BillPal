# Category Service Migration Guide

Dieser Guide erklärt, wie die aktuellen Category-Services später mit einem branch gemerged werden können, der bereits Internationalisierung (i18n) implementiert hat.

## 🔄 Migration Strategy

### Current State (persistenz branch)
- `ConfigurableCategoryService`: Basis-Kategorisierung mit hardcoded deutschen/englischen Namen
- `MultiLanguageUserCategoryService`: User-Keywords pro Sprache
- `CategoryLocaleService`: Locale-Detection mit Fallbacks

### Target State (nach Merge mit i18n branch)
- Integration mit `flutter_localizations` und `.arb` files
- Dynamische Kategorie-Namen aus Lokalisierungsdateien
- Erweiterte Sprach-Unterstützung

## 📋 Migration Steps

### Step 1: Lokalisierungsdateien erweitern
```dart
// lib/l10n/app_de.arb
{
  "category_restaurant_food": "Restaurant & Essen",
  "category_entertainment": "Unterhaltung", 
  "category_transport": "Transport",
  "category_shopping": "Einkaufen",
  "category_housing": "Wohnen & Fixkosten",
  "category_other": "Sonstiges"
}

// lib/l10n/app_en.arb  
{
  "category_restaurant_food": "Restaurant & Food",
  "category_entertainment": "Entertainment",
  "category_transport": "Transport", 
  "category_shopping": "Shopping",
  "category_housing": "Housing & Fixed Costs",
  "category_other": "Other"
}
```

### Step 2: CategoryLocaleService erweitern
```dart
class CategoryLocaleService {
  /// Integration mit AppLocalizations (nach i18n merge)
  static String getCurrentLocale(BuildContext? context) {
    if (context != null) {
      // AFTER MERGE: Use AppLocalizations
      // final appLocalizations = AppLocalizations.of(context);
      // return appLocalizations.localeName;
      
      // CURRENT: Fallback implementation
      final locale = Localizations.localeOf(context);
      return locale.languageCode.toLowerCase();
    }
    return 'de';
  }

  /// AFTER MERGE: Use AppLocalizations for category names
  static String getCategoryName(CategoryDefinition category, String locale, [BuildContext? context]) {
    // FUTURE: Use localized strings
    // if (context != null) {
    //   final localizations = AppLocalizations.of(context);
    //   return localizations.getCategoryName(category.id);
    // }
    
    // CURRENT: Hardcoded names
    switch (locale) {
      case 'en': return category.nameEN;
      case 'de':
      default: return category.nameDE;
    }
  }
}
```

### Step 3: CategoryDefinition refactoring
```dart
class CategoryDefinition {
  final String id;
  // DEPRECATED after merge: Remove hardcoded names
  @deprecated
  final String nameDE;
  @deprecated  
  final String nameEN;
  
  final String icon;
  final Map<String, List<String>> keywords;
  final int priority;

  const CategoryDefinition({
    required this.id,
    @deprecated this.nameDE = '',
    @deprecated this.nameEN = '',
    required this.icon,
    required this.keywords,
    required this.priority,
  });
  
  // AFTER MERGE: Add localized name getter
  // String getLocalizedName(BuildContext context) {
  //   final localizations = AppLocalizations.of(context);
  //   return localizations.getCategoryName(id);
  // }
}
```

## ⚠️ Breaking Changes Prevention

### Compatibility Layer
```dart
/// Compatibility wrapper für sanfte Migration
class CategoryServiceCompat {
  static String getCategoryName(CategoryDefinition category, BuildContext? context) {
    if (context != null) {
      // Try new i18n method first
      try {
        // return category.getLocalizedName(context);
      } catch (e) {
        // Fallback to old method
      }
    }
    
    // Fallback to current implementation
    final locale = CategoryLocaleService.getCurrentLocale(context);
    return CategoryLocaleService.getCategoryName(category, locale);
  }
}
```

## 🔧 Migration Checklist

- [ ] Backup current category service implementations
- [ ] Create .arb files with category translations
- [ ] Update CategoryLocaleService to use AppLocalizations
- [ ] Add compatibility layer for smooth transition
- [ ] Update all UI components to use new localized names
- [ ] Run migration tests
- [ ] Update documentation

## 🧪 Testing Strategy

```dart
void main() {
  group('Migration Compatibility Tests', () {
    testWidgets('Old and new category names match', (tester) async {
      // Test that migration doesn't break existing functionality
    });
    
    test('User keywords work with both old and new system', () {
      // Test backward compatibility
    });
  });
}
```

## 📁 File Structure After Merge

```
lib/
├── l10n/
│   ├── app_de.arb                    # German translations
│   ├── app_en.arb                    # English translations
│   └── app_localizations.dart        # Generated
├── shared/application/services/
│   ├── category_service.dart         # Main service (merged)
│   ├── user_category_service.dart    # User customizations
│   └── category_locale_service.dart  # Locale handling
└── features/settings/
    └── category_management_page.dart # UI with i18n support
```

## 🚀 Benefits After Migration

1. **Full i18n support**: Categories work with any language
2. **Maintainable translations**: Centralized in .arb files  
3. **Extensible**: Easy to add new languages
4. **Consistent**: Same i18n system as rest of app
5. **User-friendly**: Localized category management UI

## 🔄 Rollback Plan

If migration causes issues:
1. Keep old services as `*_legacy.dart`
2. Feature flag to switch between old/new system
3. Gradual rollout with A/B testing
4. Monitor error rates and user feedback