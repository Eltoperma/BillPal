import 'package:billpal/app/app.dart';
import 'package:billpal/core/theme/theme_controller.dart';
import 'package:billpal/l10n/locale_controller.dart';
import 'package:billpal/core/app_mode/app_mode_service.dart';
import 'package:billpal/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite für Desktop-Plattformen initialisieren (Windows/Linux)
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux) {
    AppLogger.sql.info('🔧 Windows/Linux erkannt - SQLite FFI wird initialisiert');
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for desktop platforms
    databaseFactory = databaseFactoryFfi;
    AppLogger.sql.success('✅ SQLite FFI erfolgreich initialisiert für Desktop');
  } else {
    AppLogger.sql.info('📱 Mobile/macOS erkannt - Standard SQLite wird verwendet');
  }

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
  AppLogger.globalInfo(appModeService.getDebugInfo());

  Intl.defaultLocale = 'de_DE';
  runApp(
    BillPalApp(
      themeController: themeController,
      localeController: localeController,
    ),
  );
}
