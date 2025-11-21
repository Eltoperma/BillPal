import 'package:flutter/material.dart';
import 'package:billpal/features/settings/application/services/configurable_category_service.dart';
import 'package:billpal/features/settings/application/services/multi_language_category_service.dart';

/// Seite zur Verwaltung von Kategorien und User-Korrekturen
class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final _userCategoryService = MultiLanguageUserCategoryService();
  List<CategoryDefinition> _categories = [];
  List<UserCategoryCorrection> _userCorrections = [];
  bool _isLoading = true;
  late String _currentLocale;
  
  // Temporary localization helper
  String _getLocalizedString(String key, {String? param}) {
    final isGerman = _currentLocale == 'de';
    switch (key) {
      case 'categoryManage':
        return isGerman ? 'Kategorien verwalten' : 'Manage categories';
      case 'categorySettings':
        return isGerman ? 'Kategorien-Einstellungen' : 'Category Settings';
      case 'categorySettingsDesc':
        return isGerman ? 'Hier kannst du die automatische Kategorisierung anpassen und eigene Regeln erstellen.' : 'Here you can customize automatic categorization and create your own rules.';
      case 'availableCategories':
        return isGerman ? 'Verfügbare Kategorien' : 'Available Categories';
      case 'standardKeywords':
        return isGerman ? 'Standard Keywords:' : 'Standard Keywords:';
      case 'yourKeywords':
        return isGerman ? 'Deine Keywords:' : 'Your Keywords:';
      case 'keywordAdd':
        return isGerman ? 'Keyword hinzufügen' : 'Add keyword';
      case 'yourCorrections':
        return isGerman ? 'Deine Korrekturen' : 'Your Corrections';
      case 'correctionsDesc':
        return isGerman ? 'Rechnungen, bei denen du die automatische Kategorisierung korrigiert hast:' : 'Bills where you corrected the automatic categorization:';
      case 'keywordAddTitle':
        return isGerman ? 'Keyword hinzufügen' : 'Add Keyword';
      case 'keywordAddHint':
        return isGerman ? 'z.B. "pizzeria", "tankstelle"' : 'e.g. "pizzeria", "gas station"';
      case 'newKeyword':
        return isGerman ? 'Neues Keyword' : 'New Keyword';
      case 'cancel':
        return isGerman ? 'Abbrechen' : 'Cancel';
      case 'add':
        return isGerman ? 'Hinzufügen' : 'Add';
      case 'andMore':
        return isGerman ? '... und $param weitere' : '... and $param more';
      case 'keywords':
        return isGerman ? 'Keywords' : 'Keywords';
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    // Defer loading until after first build
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      _currentLocale = CategoryLocaleService.getCurrentLocale(context);
      
      _categories = ConfigurableCategoryService.getAllCategories();
      await _userCategoryService.loadUserKeywords(_currentLocale);
      _userCorrections = await _userCategoryService.getAllCorrections();
      
    } catch (e) {
      // Silent error handling
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedString('categoryManage')),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildCategoriesList(),
                  const SizedBox(height: 32),
                  _buildUserCorrections(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.category, size: 28),
                const SizedBox(width: 12),
                Text(
                  _getLocalizedString('categorySettings'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getLocalizedString('categorySettingsDesc'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLocalizedString('availableCategories'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ..._categories.map((category) => _buildCategoryCard(category)),
      ],
    );
  }

  Widget _buildCategoryCard(CategoryDefinition category) {
    final userKeywords = _userCategoryService.getUserKeywords(category.id, _currentLocale);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
        title: Text(CategoryLocaleService.getCategoryName(category, _currentLocale)),
        subtitle: Text('${category.keywords[_currentLocale]?.length ?? 0} ${_getLocalizedString('keywords')}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedString('standardKeywords'),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: (category.keywords[_currentLocale] ?? [])
                      .take(10) // Zeige nur die ersten 10
                      .map((keyword) => Chip(
                            label: Text(keyword),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
                if ((category.keywords[_currentLocale]?.length ?? 0) > 10) 
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _getLocalizedString('andMore', param: '${(category.keywords[_currentLocale]?.length ?? 0) - 10}'),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                
                if (userKeywords.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _getLocalizedString('yourKeywords'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: userKeywords
                        .map((keyword) => Chip(
                              label: Text(keyword),
                              backgroundColor: Colors.blue.shade50,
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => _removeUserKeyword(category.id, keyword),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ],
                
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _addUserKeyword(category.id),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(_getLocalizedString('keywordAdd')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCorrections() {
    if (_userCorrections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLocalizedString('yourCorrections'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          _getLocalizedString('correctionsDesc'),
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),
        for (final correction in _userCorrections) _buildCorrectionCard(correction),
      ],
    );
  }

  Widget _buildCorrectionCard(UserCategoryCorrection correction) {
    return Card(
      child: ListTile(
        title: Text(correction.billTitle),
        subtitle: Text(
          '${correction.originalCategory} → ${correction.correctedCategory}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _removeCorrection(correction),
        ),
      ),
    );
  }

  Future<void> _addUserKeyword(String categoryId) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedString('keywordAddTitle')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: _getLocalizedString('keywordAddHint'),
            labelText: _getLocalizedString('newKeyword'),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_getLocalizedString('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim().toLowerCase());
              }
            },
            child: Text(_getLocalizedString('add')),
          ),
        ],
      ),
    );

    if (result != null) {
      await _userCategoryService.addUserKeyword(categoryId, result, _currentLocale);
      _loadData();
    }
  }

  Future<void> _removeUserKeyword(String categoryId, String keyword) async {
    await _userCategoryService.removeUserKeyword(categoryId, keyword, _currentLocale);
    _loadData();
  }

  Future<void> _removeCorrection(UserCategoryCorrection correction) async {
    await _userCategoryService.removeCorrection(correction.id);
    _loadData();
  }
}



