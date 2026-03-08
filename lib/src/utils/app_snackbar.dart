import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppSnackbar {
  AppSnackbar._();

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show(
    String message, {
    bool success = true,
  }) {
    messengerKey.currentState?.hideCurrentSnackBar();
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.primary : AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
