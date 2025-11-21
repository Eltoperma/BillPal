import 'package:billpal/features/settings/presentation/widgets/options_row.dart';
import 'package:billpal/features/settings/presentation/widgets/previews.dart';
import 'package:billpal/l10n/locale_controller.dart';
import 'package:flutter/material.dart';

/// Baut die Sprach-Optionen. (Bei mehr Sprachen hier erweitern.)
/// Note: Hier verwenden wir keine L10n, da die Sprachnamen in ihrer Originalsprache angezeigt werden sollen
List<OptionItem<Locale?>> buildLocaleOptions(LocaleController c) => [
  OptionItem<Locale?>(
    id: null,
    title: 'System',
    preview: PreviewTile.localeSystem(),
    isSelected: () => c.locale == null,
    onSelect: () => c.setLocale(null),
  ),
  OptionItem<Locale?>(
    id: const Locale('de'),
    title: 'Deutsch',
    preview: PreviewTile.localeDe(),
    isSelected: () => c.locale?.languageCode == 'de',
    onSelect: () => c.setLocale(const Locale('de')),
  ),
  OptionItem<Locale?>(
    id: const Locale('en'),
    title: 'English',
    preview: PreviewTile.localeEn(),
    isSelected: () => c.locale?.languageCode == 'en',
    onSelect: () => c.setLocale(const Locale('en')),
  ),
];