import 'package:flutter/material.dart';
import 'package:billpal/models/invoice.dart';
import 'package:billpal/services/user_service.dart';
import 'package:billpal/features/friends/presentation/pages/friends_management_page.dart';

/// Collapsible Friends Card für das Dashboard
/// Zeigt eine Vorschau der Freunde mit Möglichkeit zum Erweitern
class FriendsPreviewCard extends StatefulWidget {
  const FriendsPreviewCard({super.key});

  @override
  State<FriendsPreviewCard> createState() => _FriendsPreviewCardState();
}

class _FriendsPreviewCardState extends State<FriendsPreviewCard> {
  final UserService _userService = UserService();
  List<Person> _friends = [];
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoading = true);
    try {
      final friends = await _userService.getAllFriends();
      setState(() {
        _friends = friends;
        _isLoading = false;
      });
    } catch (e) {
      print('⚠️ FriendsPreviewCard: Fehler beim Laden: $e');
      setState(() => _isLoading = false);
    }
  }

  void _navigateToFriendsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FriendsManagementPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // Header
          ListTile(
            leading: Icon(
              Icons.people_outlined,
              color: colorScheme.primary,
            ),
            title: Text(
              'Meine Freunde',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: _isLoading
                ? Text('Lädt...')
                : Text('${_friends.length} Freund${_friends.length == 1 ? '' : 'e'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: _showAddFriendDialog,
                  tooltip: 'Freund hinzufügen',
                ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),

          // Content (Collapsible)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          // Footer Actions
          if (!_isExpanded) _buildFooterActions(),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_friends.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Noch keine Freunde hinzugefügt',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddFriendDialog,
              icon: Icon(Icons.person_add),
              label: Text('Ersten Freund hinzufügen'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Friends Avatars (horizontal scroll)
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _friends.length,
            itemBuilder: (context, index) {
              final friend = _friends[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        friend.name.isNotEmpty 
                            ? friend.name[0].toUpperCase() 
                            : '?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 48,
                      child: Text(
                        friend.name,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Actions
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showAddFriendDialog,
                  icon: Icon(Icons.person_add),
                  label: Text('Freund hinzufügen'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _navigateToFriendsPage,
                  icon: Icon(Icons.manage_accounts),
                  label: Text('Alle verwalten'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Friends Avatars Preview (nur erste 4)
          Expanded(
            child: SizedBox(
              height: 32,
              child: _friends.isEmpty
                  ? Text(
                      'Keine Freunde',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    )
                  : Stack(
                      children: _friends
                          .take(4)
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final friend = entry.value;
                        return Positioned(
                          left: index * 20.0,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              friend.name.isNotEmpty 
                                  ? friend.name[0].toUpperCase() 
                                  : '?',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
          
          TextButton(
            onPressed: _navigateToFriendsPage,
            child: Text('Alle anzeigen'),
          ),
        ],
      ),
    );
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
}

/// Simple Add Friend Dialog (reused from friends page)
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