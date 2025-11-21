import 'package:billpal/features/settings/presentation/widgets/drawer_nav_list.dart';
import 'package:billpal/features/settings/presentation/options/locale_options.dart';
import 'package:billpal/features/settings/presentation/options/theme_options.dart';
import 'package:billpal/features/settings/presentation/widgets/options_row.dart';
import 'package:billpal/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:billpal/core/theme/theme_controller.dart';
import 'package:billpal/l10n/locale_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.themeController,
    required this.localeController,
  });

  final ThemeController themeController;
  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sc = Theme.of(context).colorScheme;

    // --- Theme-Optionen ---
    final themeOptions = buildThemeOptions(themeController);

    // --- Sprach-Optionen ---
    final localeOptions = buildLocaleOptions(localeController);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const FlutterLogo(size: 28),
                const SizedBox(width: 12),
                Text(l10n.appTitle, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),

            const DrawerNavList(),

            _sectionLabel(context, l10n.drawerAppearance, sc.onSurfaceVariant),
            OptionsRow(options: themeOptions), // immer 1 Reihe (max. 3)

            const SizedBox(height: 20),

            _sectionLabel(context, l10n.drawerLanguage, sc.onSurfaceVariant),
            OptionsRow(options: localeOptions), // immer 1 Reihe (max. 3)

            const SizedBox(height: 12),
            Text(
              l10n.drawerLanguageInfo,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: sc.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext ctx, String text, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: Theme.of(
        ctx,
      ).textTheme.labelSmall?.copyWith(color: color, letterSpacing: .4),
    ),
  );
}
