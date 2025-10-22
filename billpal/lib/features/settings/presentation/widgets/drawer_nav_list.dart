import 'package:flutter/material.dart';

class DrawerNavList extends StatelessWidget {
  const DrawerNavList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NavTile(
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          route: '/',
        ),
        _NavTile(
          icon: Icons.receipt_long_outlined,
          label: 'Meine Rechnungen',
          route: '/bills',
        ),
        _NavTile(icon: Icons.history, label: 'Historie', route: '/history'),
        _NavTile(
          icon: Icons.people_outlined,
          label: 'Meine Freunde',
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
