import 'package:billpal/core/theme/app_theme.dart';
import 'package:billpal/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:billpal/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class BillPalApp extends StatelessWidget {
  final ThemeController themeController;
  const BillPalApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    // Rebuild, wenn ThemeMode geändert wird
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          supportedLocales: const [
            Locale('de'),
            Locale('en'),
          ],

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.mode,

          home: DashboardPage(themeController: themeController),
        );
      },
    );
  }
}
