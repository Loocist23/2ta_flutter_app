import 'package:flutter/material.dart';

/// Centralizes the color palette so widgets stay consistent across the app.
class AppColors {
  AppColors._();

  // Primary and secondary colors from CSS
  static const Color primary = Color(0xFFE7314B);
  static const Color secondary1 = Color(0xFFC83377);
  static const Color secondary2 = Color(0xFF96468F);
  static const Color secondary3 = Color(0xFF5F508E);
  static const Color secondary4 = Color(0xFF375078);
  static const Color secondary5 = Color(0xFF2F4858);

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grayLight = Color(0xFFF5F5F5);
  static const Color gray = Color(0xFFE0E0E0);
  static const Color grayDark = Color(0xFF757575);

  // Text colors
  static const Color text = Color(0xFF333333);
  static const Color textLight = Color(0xFF666666);

  // Semantic colors
  static const Color danger = Color(0xFFDC3545);
  static const Color dangerLight = Color(0xFFF8D7DA);
  static const Color error = Color(0xFFDC3545);

  // Background colors
  static const Color background = white;
  static const Color cardBackground = white;
}
