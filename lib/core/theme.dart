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
    // Bundled OFL family with both Persian and Latin glyphs, so UI labels
    // render consistently instead of relying on platform font fallback.
    fontFamily: 'Vazirmatn',
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF0E1016)
        : scheme.surface,
    sliderTheme: const SliderThemeData(
      showValueIndicator: ShowValueIndicator.onDrag,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: brightness == Brightness.dark
          ? const Color(0xFF141822)
          : scheme.surface,
      elevation: 0,
    ),
  );
}
