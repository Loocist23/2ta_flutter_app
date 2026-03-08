import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.gray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFEEF2F8),
      selectedColor: AppColors.primary,
      labelStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w600),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
