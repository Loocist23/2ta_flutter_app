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
    fontFamily: 'Montserrat',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.text,
        fontFamily: 'Montserrat',
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: 'Montserrat', color: AppColors.text),
      bodyMedium: TextStyle(fontFamily: 'Montserrat', color: AppColors.text),
      bodySmall: TextStyle(fontFamily: 'Montserrat', color: AppColors.text),
      labelLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
      labelSmall: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
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
      labelStyle: const TextStyle(fontFamily: 'Montserrat'),
      hintStyle: const TextStyle(fontFamily: 'Montserrat'),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFEEF2F8),
      selectedColor: AppColors.primary,
      labelStyle: const TextStyle(
        color: AppColors.textLight,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontFamily: 'Montserrat',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
      ),
    ),
  );
}
