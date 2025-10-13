import 'package:billpal/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';

class ThemeToggle extends StatelessWidget {
  final ThemeController controller;
  const ThemeToggle({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ThemeMode>(
      icon: const Icon(Icons.brightness_6),
      initialValue: controller.mode,
      onSelected: controller.setMode,
      itemBuilder: (context) => const [
        PopupMenuItem(value: ThemeMode.system, child: Text('System')),
        PopupMenuItem(value: ThemeMode.light,  child: Text('Hell')),
        PopupMenuItem(value: ThemeMode.dark,   child: Text('Dunkel')),
      ],
    );
  }
}
