import 'package:flutter/material.dart';

/// Moroccan-inspired palette, consistent with أرقامي / حروفي.
class AppColors {
  static const teal = Color(0xFF0E7C7B);
  static const gold = Color(0xFFD4A017);
  static const terracotta = Color(0xFFC1440E);
  static const sand = Color(0xFFF4E9D8);
  static const night = Color(0xFF1B1F3B);

  /// One distinct color per shape, used both for the 3D render and UI chips.
  static const Map<String, Color> shapeColors = {
    'circle': teal,
    'square': terracotta,
    'triangle': gold,
    'rectangle': Color(0xFF2E86AB),
    'oval': Color(0xFF6A4C93),
    'star': Color(0xFFF4A300),
    'heart': Color(0xFFE63946),
    'rhombus': Color(0xFF06A77D),
    'pentagon': Color(0xFF9C6644),
    'hexagon': Color(0xFF3D5A80),
  };
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo', // add Cairo or similar Arabic-friendly font to assets/fonts
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      secondary: AppColors.gold,
    ),
    scaffoldBackgroundColor: AppColors.sand,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.teal,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
  );
}
