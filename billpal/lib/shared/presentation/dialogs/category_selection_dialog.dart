import 'package:flutter/material.dart';
import 'package:billpal/features/settings/application/services/configurable_category_service.dart';
import 'package:billpal/features/settings/application/services/multi_language_category_service.dart';

/// Dialog zur Auswahl/Korrektur einer Kategorie
class CategorySelectionDialog extends StatefulWidget {
  final String currentCategory;
  final String billTitle;

  const CategorySelectionDialog({
    super.key,
    required this.currentCategory,
    required this.billTitle,
  });

  @override
  State<CategorySelectionDialog> createState() => _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  late String _selectedCategory;
  List<CategoryDefinition> _categories = [];
  late String _currentLocale;
  
  // Temporary localization helper until flutter_gen is available
  String _getLocalizedString(String key) {
    final isGerman = _currentLocale == 'de';
    switch (key) {
      case 'categorySelect':
        return isGerman ? 'Kategorie auswählen' : 'Select category';
      case 'categoryEdit':
        return isGerman ? 'Kategorie bearbeiten' : 'Edit category';
      case 'categoryAutoDetected':
        return isGerman ? 'Automatisch erkannt:' : 'Auto-detected:';
      case 'categoryDetectedKeywords':
        return isGerman ? 'Erkannte Keywords:' : 'Detected keywords:';
      case 'categorySelectCorrect':
        return isGerman ? 'Wähle die richtige Kategorie:' : 'Select the correct category:';
      case 'categoryManage':
        return isGerman ? 'Kategorien verwalten' : 'Manage categories';
      case 'categoryOtherDesc':
        return isGerman ? 'Keine der obigen Kategorien passt' : 'None of the above categories fit';
      case 'cancel':
        return isGerman ? 'Abbrechen' : 'Cancel';
      case 'confirm':
        return isGerman ? 'Bestätigen' : 'Confirm';
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentCategory;
    _loadCategories();
  }

  void _loadCategories() {
    _currentLocale = CategoryLocaleService.getCurrentLocale(context);
    _categories = ConfigurableCategoryService.getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    // Analysiere den Titel für Debug-Info
    final analysis = ConfigurableCategoryService.analyzeTitle(widget.billTitle);
    
    return AlertDialog(
      title: Text(_getLocalizedString('categorySelect')),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aktuelle automatische Kategorisierung
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_currentLocale == 'de' ? 'Rechnung' : 'Receipt'}: "${widget.billTitle}"',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getLocalizedString('categoryAutoDetected')} ${widget.currentCategory}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  if (analysis.bestMatch?.matchedKeywords.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_getLocalizedString('categoryDetectedKeywords')} ${analysis.bestMatch!.matchedKeywords.join(', ')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            Text(
              _getLocalizedString('categorySelectCorrect'),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            
            // Kategorie-Auswahl
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _categories.length + 1, // +1 für "Sonstiges"
                itemBuilder: (context, index) {
                  if (index == _categories.length) {
                    // Sonstiges-Option
                    final otherCategoryName = CategoryLocaleService.getOtherCategoryName(_currentLocale);
                    return RadioListTile<String>(
                      title: Text(otherCategoryName),
                      subtitle: Text(_getLocalizedString('categoryOtherDesc')),
                      value: otherCategoryName,
                      groupValue: _selectedCategory,
                      onChanged: (value) {
                        setState(() => _selectedCategory = value!);
                      },
                    );
                  }
                  
                  final category = _categories[index];
                  final categoryName = CategoryLocaleService.getCategoryName(category, _currentLocale);
                  return RadioListTile<String>(
                    title: Row(
                      children: [
                        Text(category.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(categoryName),
                      ],
                    ),
                    subtitle: Text(
                      '${category.keywords[_currentLocale]?.take(3).join(', ') ?? ''}...',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    value: categoryName,
                    groupValue: _selectedCategory,
                    onChanged: (value) {
                      setState(() => _selectedCategory = value!);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_getLocalizedString('cancel')),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Schließe Dialog
            Navigator.of(context).pushNamed('/categories'); // Navigiere zu Category Management
          },
          child: Text(_getLocalizedString('categoryManage')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedCategory),
          child: Text(_getLocalizedString('confirm')),
        ),
      ],
    );
  }
}

