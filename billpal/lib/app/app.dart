import 'package:billpal/core/theme/app_theme.dart';
import 'package:billpal/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:billpal/features/friends/presentation/pages/friends_management_page.dart';
import 'package:billpal/features/bills/presentation/pages/bill_history_page.dart';
import 'package:billpal/features/bills/presentation/pages/bill_detail_page.dart';
import 'package:billpal/features/settings/presentation/pages/category_management_page.dart';
import 'package:billpal/shared/domain/entities.dart';
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

          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder: (_) => DashboardPage(
                    themeController: themeController,
                    localeController: localeController,
                  ),
                );
              case '/friends':
                return MaterialPageRoute(
                  builder: (_) => const FriendsManagementPage(),
                );
              case '/history':
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (_) => BillHistoryPage(
                    filterBy: args?['filterBy'] as String?,
                    statusFilter: args?['statusFilter'] as BillStatus?,
                  ),
                );
              case '/categories':
                return MaterialPageRoute(
                  builder: (_) => const CategoryManagementPage(),
                );
              case '/bill-detail':
                final bill = settings.arguments as SharedBill;
                return MaterialPageRoute(
                  builder: (_) => BillDetailPage(bill: bill),
                );
              default:
                return MaterialPageRoute(
                  builder: (_) => DashboardPage(
                    themeController: themeController,
                    localeController: localeController,
                  ),
                );
            }
          },
        );
      },
    );
  }
}
