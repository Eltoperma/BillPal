import 'package:billpal/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DrawerNavList extends StatelessWidget {
  const DrawerNavList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _NavTile(
          icon: Icons.dashboard_outlined,
          label: l10n.drawerDashboard,
          route: '/',
        ),
        _NavTile(icon: Icons.history, label: l10n.drawerHistory, route: '/history'),
        _NavTile(
          icon: Icons.people_outlined,
          label: l10n.drawerMyFriends,
          route: '/friends',
        ),
        const Divider(height: 32),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        // Dashboard ist die Hauptseite - verwende replacement
        // Andere Seiten sind Einschübe - verwende push
        if (route == '/') {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}
