import 'package:flutter/material.dart';
import 'package:billpal/models/invoice.dart'; // Zentrale Person-Klasse
import 'package:billpal/services/user_service.dart'; // Zentrale Freunde-Verwaltung
import 'package:billpal/core/logging/app_logger.dart';
import 'package:billpal/core/app_mode/app_mode_service.dart';

class FriendsManagementPage extends StatefulWidget {
  const FriendsManagementPage({super.key});

  @override
  State<FriendsManagementPage> createState() => _FriendsManagementPageState();
}

class _FriendsManagementPageState extends State<FriendsManagementPage> {
  final UserService _userService = UserService();
  final AppModeService _appMode = AppModeService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Person> _friends = [];
  List<Person> _filteredFriends = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    try {
      final friends = await _userService.getAllFriends();
      setState(() {
        _friends = friends;
        _filteredFriends = friends;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.users.error('⚠️ FriendsPage: Fehler beim Laden der Freunde: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Freunde: $e')),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      _filteredFriends = query.isEmpty
          ? _friends
          : _friends.where((friend) =>
              friend.name.toLowerCase().contains(query) ||
              (friend.email?.toLowerCase().contains(query) ?? false)
            ).toList();
    });
  }

  Future<void> _showAddFriendDialog() async {
    final result = await showDialog<Person>(
      context: context,
      builder: (context) => _AddFriendDialog(),
    );

    if (result != null) {
      try {
        await _userService.addFriend(
          name: result.name,
          email: result.email,
          phone: result.phone,
        );
        await _loadFriends(); // Refresh
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${result.name} wurde hinzugefügt')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Hinzufügen: $e')),
          );
        }
      }
    }
  }

  Future<void> _removeFriend(Person friend) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Freund entfernen'),
        content: Text('Möchtest du ${friend.name} wirklich aus deiner Freundesliste entfernen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Entfernen'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _userService.removeFriend(friend.id);
        if (success) {
          await _loadFriends(); // Refresh
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${friend.name} wurde entfernt')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Entfernen: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Meine Freunde'),
            const SizedBox(width: 8),
            // TODO: [CLEANUP] Debug-Badge entfernen nach Branch-Cleanup
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _appMode.isDemoMode ? Colors.orange.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _appMode.currentMode.name,
                style: TextStyle(
                  fontSize: 10,
                  color: _appMode.isDemoMode ? Colors.orange.shade800 : Colors.green.shade800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _showAddFriendDialog,
            tooltip: 'Freund hinzufügen',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Freunde suchen...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
              ),
            ),
          ),
          
          // Friends List oder Loading/Empty State
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredFriends.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadFriends,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredFriends.length,
                          itemBuilder: (context, index) {
                            final friend = _filteredFriends[index];
                            return _FriendTile(
                              friend: friend,
                              onRemove: () => _removeFriend(friend),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearchQuery = _searchQuery.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? Icons.search_off : Icons.people_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery 
                ? 'Keine Freunde gefunden für "$_searchQuery"'
                : 'Noch keine Freunde hinzugefügt',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasSearchQuery
                ? 'Versuche einen anderen Suchbegriff'
                : 'Füge Freunde hinzu, um Rechnungen zu teilen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (!hasSearchQuery) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddFriendDialog,
              icon: Icon(Icons.person_add),
              label: Text('Ersten Freund hinzufügen'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Friend Tile Widget
class _FriendTile extends StatelessWidget {
  final Person friend;
  final VoidCallback onRemove;

  const _FriendTile({
    required this.friend,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(friend.name),
        subtitle: friend.email != null || friend.phone != null
            ? Text(friend.email ?? friend.phone ?? '')
            : null,
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('Entfernen'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'remove') {
              onRemove();
            }
          },
        ),
      ),
    );
  }
}

/// Add Friend Dialog
class _AddFriendDialog extends StatefulWidget {
  @override
  State<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<_AddFriendDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Freund hinzufügen'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Name ist erforderlich';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Telefon (optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final person = Person(
                id: '', // Wird vom Service gesetzt
                name: _nameController.text.trim(),
                email: _emailController.text.trim().isEmpty 
                    ? null : _emailController.text.trim(),
                phone: _phoneController.text.trim().isEmpty 
                    ? null : _phoneController.text.trim(),
                createdAt: DateTime.now(),
              );
              Navigator.pop(context, person);
            }
          },
          child: Text('Hinzufügen'),
        ),
      ],
    );
  }
}