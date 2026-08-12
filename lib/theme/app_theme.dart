import 'package:flutter/material.dart';

/// Moroccan-inspired palette, consistent with أرقامي / حروفي.
class AppColors {
  static const teal = Color(0xFF0E7C7B);
  static const gold = Color(0xFFD4A017);
  static const terracotta = Color(0xFFC1440E);
  static const sand = Color(0xFFF4E9D8);
  static const night = Color(0xFF1B1F3B);

  // Unified feedback colors - used everywhere a correct/incorrect answer
  // is highlighted, so every activity screen looks and feels consistent.
  static const success = Color(0xFF2E9E5B);
  static const successBg = Color(0xFFE1F5EA);
  static const error = Color(0xFFD64550);
  static const errorBg = Color(0xFFFBE4E6);

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
      elevation: 0,
    ),
    // One consistent button look across every activity screen instead of
    // each screen styling its own ElevatedButton.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      shadowColor: AppColors.night.withOpacity(0.15),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.sand,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.teal.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: AppColors.night),
      titleLarge: TextStyle(fontWeight: FontWeight.bold, color: AppColors.night),
    ),
  );
}

/// Shared answer-tile decoration for multiple-choice activities (find real
/// life, sides quiz, calc) - keeps the "selected/correct/wrong" look
/// identical across all three instead of each screen rolling its own.
BoxDecoration answerTileDecoration({required bool? isSelectedAndCorrect}) {
  Color borderColor = Colors.grey.shade300;
  Color? bg;
  if (isSelectedAndCorrect != null) {
    borderColor = isSelectedAndCorrect ? AppColors.success : AppColors.error;
    bg = isSelectedAndCorrect ? AppColors.successBg : AppColors.errorBg;
  }
  return BoxDecoration(
    color: bg ?? Colors.white,
    border: Border.all(color: borderColor, width: 2.5),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 3)),
    ],
  );
}
