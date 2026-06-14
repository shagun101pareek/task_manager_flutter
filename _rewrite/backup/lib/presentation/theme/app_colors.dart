import 'package:flutter/material.dart';

/// Single blue palette used across the app.
abstract final class AppColors {
  static const primary = Color(0xFF2196F3);
  static const primaryDark = Color(0xFF1976D2);
  static const primaryLight = Color(0xFF64B5F6);
  static const primaryPale = Color(0xFFE3F2FD);
  static const surface = Color(0xFFFAFBFF);
  static const textPrimary = Color(0xFF37474F);
  static const textSecondary = Color(0xFF78909C);
  static const border = Color(0xFFBBDEFB);

  static const darkSurface = Color(0xFF121820);
  static const darkTextPrimary = Color(0xFFECEFF1);
  static const darkTextSecondary = Color(0xFF90A4AE);
  static const darkCard = Color(0xFF1E2832);
  static const darkBorder = Color(0xFF37474F);

  static Color textPrimaryFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }

  static Color textSecondaryFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : textSecondary;
  }
}
