import 'package:flutter/material.dart';

/// Raw brand colors used only where no [ThemeData] is available yet (the
/// splash screen, which renders before [ThemeController] restores the user's
/// chosen theme). Everywhere else, themes come from `forge_palette.dart` +
/// `app_theme.dart` — see [ForgePalettes] for the full Dark/Light/AMOLED/
/// Glass/Ocean/Forest/Purple/Minimal/Cyberpunk/Neon set.
class AppColors {
  const AppColors._();

  static const Color background = Color(0xFF0B0B0F);
  static const Color surface = Color(0xFF16161D);
  static const Color surfaceElevated = Color(0xFF1E1E27);
  static const Color border = Color(0xFF2A2A35);

  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryVariant = Color(0xFF8E7CFF);
  static const Color accent = Color(0xFF00D9C0);

  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFA0A0AC);
  static const Color textDisabled = Color(0xFF5C5C66);

  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);

  static const List<Color> primaryGradient = [
    Color(0xFF6C5CE7),
    Color(0xFF00D9C0),
  ];

  static const Color backgroundLight = Color(0xFFF7F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF0F0F5);
  static const Color borderLight = Color(0xFFE2E2E8);
  static const Color textPrimaryLight = Color(0xFF16161D);
  static const Color textSecondaryLight = Color(0xFF6B6B76);
}
