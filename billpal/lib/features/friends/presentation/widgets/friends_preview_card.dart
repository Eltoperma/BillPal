import 'package:flutter/material.dart';
import 'package:billpal/shared/domain/entities.dart';
import 'package:billpal/shared/application/services.dart';
import 'package:billpal/core/app_mode/app_mode_service.dart';
import 'package:billpal/features/friends/presentation/pages/friends_management_page.dart';
import 'package:billpal/core/logging/app_logger.dart';
import 'package:billpal/l10n/app_localizations.dart';

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
    
    // Listener für Mode-Changes
    AppModeService().addListener(_onModeChanged);
    
    _loadFriends();
  }

  @override
  void dispose() {
    AppModeService().removeListener(_onModeChanged);
    super.dispose();
  }

  /// Callback bei Mode-Wechsel - lädt Freunde neu
  void _onModeChanged() {
    AppLogger.dashboard.info('🔄 FriendsPreviewCard: Mode gewechselt zu ${AppModeService().currentMode.name} - Reload');
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
      AppLogger.dashboard.error('⚠️ FriendsPreviewCard: Fehler beim Laden: $e');
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.myFriends,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: _isLoading
                ? Text(l10n.loading)
                : Text(_friends.length == 1 ? l10n.friendCount(_friends.length) : l10n.friendCountPlural(_friends.length)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: _showAddFriendDialog,
                  tooltip: l10n.addFriend,
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
    final l10n = AppLocalizations.of(context)!;
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
              l10n.noFriendsYet,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddFriendDialog,
              icon: const Icon(Icons.person_add),
              label: Text(l10n.addFirstFriend),
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
                  icon: const Icon(Icons.person_add),
                  label: Text(l10n.addFriend),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _navigateToFriendsPage,
                  icon: const Icon(Icons.manage_accounts),
                  label: Text(l10n.manageAll),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterActions() {
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.noFriends,
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
            child: Text(l10n.showAll),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddFriendDialog() async {
    final l10n = AppLocalizations.of(context)!;
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
            SnackBar(content: Text(l10n.friendAdded(result.name))),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorAddingFriend(e.toString()))),
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
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.addFriend),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.nameLabel,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return l10n.nameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.emailLabel,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.phoneLabel,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
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
          child: Text(l10n.add),
        ),
      ],
    );
  }
}