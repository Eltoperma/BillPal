import 'package:billpal/core/theme/theme_controller.dart';
import 'package:billpal/features/settings/presentation/widgets/options_row.dart';
import 'package:billpal/features/settings/presentation/widgets/previews.dart';
import 'package:flutter/material.dart';

/// Baut die drei Theme-Optionen (Light/Dark/System).
List<OptionItem<ThemeMode>> buildThemeOptions(ThemeController c) => [
  OptionItem(
    id: ThemeMode.light,
    title: 'Light',
    preview: PreviewTile.light(),
    isSelected: () => c.mode == ThemeMode.light,
    onSelect: () => c.setMode(ThemeMode.light),
  ),
  OptionItem(
    id: ThemeMode.dark,
    title: 'Dark',
    preview: PreviewTile.dark(),
    isSelected: () => c.mode == ThemeMode.dark,
    onSelect: () => c.setMode(ThemeMode.dark),
  ),
  OptionItem(
    id: ThemeMode.system,
    title: 'System',
    preview: PreviewTile.system(),
    isSelected: () => c.mode == ThemeMode.system,
    onSelect: () => c.setMode(ThemeMode.system),
  ),
];
