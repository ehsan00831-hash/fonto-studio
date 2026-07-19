import 'package:flutter/material.dart';

/// Builds light and dark themes from the user's workspace accent colour.
ThemeData buildTheme(Color accent, Brightness brightness) {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF0E1016)
        : scheme.surface,
    sliderTheme: const SliderThemeData(
      showValueIndicator: ShowValueIndicator.always,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: brightness == Brightness.dark
          ? const Color(0xFF141822)
          : scheme.surface,
      elevation: 0,
    ),
  );
}
