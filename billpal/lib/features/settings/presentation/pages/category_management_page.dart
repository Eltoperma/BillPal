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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      _currentLocale = 'de';
      
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
        title: const Text('Kategorien verwalten'),
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
                const Text(
                  'Kategorien-Einstellungen',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Hier kannst du die automatische Kategorisierung anpassen und eigene Regeln erstellen.',
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
        const Text(
          'Verfügbare Kategorien',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
        title: Text(category.nameDE),
        subtitle: Text('${category.keywords['de']?.length ?? 0} Keywords'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Standard Keywords:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: (category.keywords['de'] ?? [])
                      .take(10) // Zeige nur die ersten 10
                      .map((keyword) => Chip(
                            label: Text(keyword),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
                if ((category.keywords['de']?.length ?? 0) > 10) 
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '... und ${(category.keywords['de']?.length ?? 0) - 10} weitere',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                
                if (userKeywords.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Deine Keywords:',
                    style: TextStyle(fontWeight: FontWeight.w600),
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
                      label: const Text('Keyword hinzufügen'),
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
        const Text(
          'Deine Korrekturen',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          'Rechnungen, bei denen du die automatische Kategorisierung korrigiert hast:',
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
        title: const Text('Keyword hinzufügen'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'z.B. "pizzeria", "tankstelle"',
            labelText: 'Neues Keyword',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim().toLowerCase());
              }
            },
            child: const Text('Hinzufügen'),
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



