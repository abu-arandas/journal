import 'package:flutter/material.dart';

class AppTheme {
  // Light theme colors
  static final ColorScheme _lightColorScheme = ColorScheme.light(
    primary: Colors.blue.shade700,
    secondary: Colors.teal.shade600,
    surface: Colors.white,
    error: Colors.red.shade700,
  );

  // Dark theme colors
  static final ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: Colors.blue.shade300,
    secondary: Colors.teal.shade300,
    surface: Colors.grey.shade900,
    error: Colors.red.shade300,
  );

  // Text themes
  static final TextTheme _textTheme = TextTheme(
    headlineLarge: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
    headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.5),
    titleLarge: TextStyle(fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16.0),
    bodyMedium: TextStyle(fontSize: 14.0),
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: _lightColorScheme.primary),
      titleTextStyle: _textTheme.titleLarge?.copyWith(color: _lightColorScheme.onSurface),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
    ),
    cardTheme: CardTheme(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: _darkColorScheme.primary),
      titleTextStyle: _textTheme.titleLarge?.copyWith(color: _darkColorScheme.onSurface),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
    ),
    cardTheme: CardTheme(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
