import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF2A9D8F);
  //static const _seed = Color.fromARGB(255, 146, 39, 196);

  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: const Color(0xFFF7F8FA), // optional override
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    appBarTheme: const AppBarTheme(centerTitle: false),
    dividerTheme: const DividerThemeData(space: 24, thickness: 1),
    // Komponenten bekommen Farben automatisch aus colorScheme
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F1113), // optional
    cardTheme: const CardThemeData(
      elevation: null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    dividerTheme: const DividerThemeData(space: 24, thickness: 1),
  );
}
