import 'package:billpal/core/theme/app_theme.dart';
import 'package:billpal/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:billpal/features/friends/presentation/pages/friends_management_page.dart';
import 'package:billpal/core/theme/theme_controller.dart';
import 'package:billpal/l10n/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class BillPalApp extends StatelessWidget {
  final ThemeController themeController;
  final LocaleController localeController;
  const BillPalApp({
    super.key,
    required this.themeController,
    required this.localeController,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuild, wenn ThemeMode geändert wird
    return AnimatedBuilder(
      animation: Listenable.merge([themeController, localeController]),
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          supportedLocales: const [Locale('de'), Locale('en')],

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          locale: localeController.locale,

          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.mode,

          routes: {
            '/': (_) => DashboardPage(
                  themeController: themeController,
                  localeController: localeController,
                ),
            '/friends': (_) => const FriendsManagementPage(),
          //  '/bills': (_) => const BillsPage(),
          //  '/history': (_) => const HistoryPage(),
          },
        );
      },
    );
  }
}
