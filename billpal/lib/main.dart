import 'package:billpal/app/app.dart';
import 'package:billpal/core/theme/theme_controller.dart';
import 'package:billpal/l10n/locale_controller.dart';
import 'package:billpal/core/app_mode/app_mode_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  final localeController = LocaleController();
  final appModeService = AppModeService();

  // Parallel initialisieren
  await Future.wait([
    themeController.load(),
    initializeDateFormatting('de_DE', ''),
    appModeService.detectInitialMode(), // Smart Detection hinzugefügt
  ]);

  // Debug Info für Development
  print(appModeService.getDebugInfo());

  Intl.defaultLocale = 'de_DE';
  runApp(
    BillPalApp(
      themeController: themeController,
      localeController: localeController,
    ),
  );
}
