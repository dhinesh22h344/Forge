import 'package:flutter/material.dart';

enum ForgeThemeId {
  dark,
  light,
  amoled,
  glass,
  ocean,
  forest,
  purple,
  minimal,
  cyberpunk,
  neon;

  String get label {
    switch (this) {
      case ForgeThemeId.dark:
        return 'Dark';
      case ForgeThemeId.light:
        return 'Light';
      case ForgeThemeId.amoled:
        return 'AMOLED';
      case ForgeThemeId.glass:
        return 'Glass';
      case ForgeThemeId.ocean:
        return 'Ocean';
      case ForgeThemeId.forest:
        return 'Forest';
      case ForgeThemeId.purple:
        return 'Purple';
      case ForgeThemeId.minimal:
        return 'Minimal';
      case ForgeThemeId.cyberpunk:
        return 'Cyberpunk';
      case ForgeThemeId.neon:
        return 'Neon';
    }
  }
}

/// A full color token set for one visual theme. [AppTheme.build] turns this
/// into a [ThemeData] — adding a theme means adding a [ForgePalette] here,
/// not touching every screen.
class ForgePalette {
  const ForgePalette({
    required this.id,
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.primary,
    required this.primaryVariant,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.success,
    required this.warning,
    required this.error,
  });

  final ForgeThemeId id;
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color primary;
  final Color primaryVariant;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color success;
  final Color warning;
  final Color error;

  List<Color> get primaryGradient => [primary, accent];

  /// Overrides just the accent color(s) on top of this palette's base
  /// background/surface/text tokens — backs "+ custom accents" without
  /// needing a dedicated palette per accent choice.
  ForgePalette withAccent(Color accentColor) {
    return ForgePalette(
      id: id,
      brightness: brightness,
      background: background,
      surface: surface,
      surfaceElevated: surfaceElevated,
      border: border,
      primary: accentColor,
      primaryVariant: accentColor,
      accent: accentColor,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textDisabled: textDisabled,
      success: success,
      warning: warning,
      error: error,
    );
  }
}

class ForgePalettes {
  const ForgePalettes._();

  static const dark = ForgePalette(
    id: ForgeThemeId.dark,
    brightness: Brightness.dark,
    background: Color(0xFF0B0B0F),
    surface: Color(0xFF16161D),
    surfaceElevated: Color(0xFF1E1E27),
    border: Color(0xFF2A2A35),
    primary: Color(0xFF6C5CE7),
    primaryVariant: Color(0xFF8E7CFF),
    accent: Color(0xFF00D9C0),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFFA0A0AC),
    textDisabled: Color(0xFF5C5C66),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
  );

  static const light = ForgePalette(
    id: ForgeThemeId.light,
    brightness: Brightness.light,
    background: Color(0xFFF7F7FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF0F0F5),
    border: Color(0xFFE2E2E8),
    primary: Color(0xFF6C5CE7),
    primaryVariant: Color(0xFF8E7CFF),
    accent: Color(0xFF00A692),
    textPrimary: Color(0xFF16161D),
    textSecondary: Color(0xFF6B6B76),
    textDisabled: Color(0xFFB4B4BE),
    success: Color(0xFF1E9E6C),
    warning: Color(0xFFB07C09),
    error: Color(0xFFD64545),
  );

  static const amoled = ForgePalette(
    id: ForgeThemeId.amoled,
    brightness: Brightness.dark,
    background: Color(0xFF000000),
    surface: Color(0xFF050505),
    surfaceElevated: Color(0xFF0D0D0D),
    border: Color(0xFF1A1A1A),
    primary: Color(0xFF7C4DFF),
    primaryVariant: Color(0xFF9B7BFF),
    accent: Color(0xFF00E5FF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF9E9E9E),
    textDisabled: Color(0xFF4D4D4D),
    success: Color(0xFF00E676),
    warning: Color(0xFFFFD740),
    error: Color(0xFFFF5252),
  );

  static const glass = ForgePalette(
    id: ForgeThemeId.glass,
    brightness: Brightness.light,
    background: Color(0xFFDDE3F0),
    surface: Color(0xCCFFFFFF),
    surfaceElevated: Color(0xE6FFFFFF),
    border: Color(0x33FFFFFF),
    primary: Color(0xFF5B8DEF),
    primaryVariant: Color(0xFF7FA6F2),
    accent: Color(0xFF6FE7DD),
    textPrimary: Color(0xFF1B1F27),
    textSecondary: Color(0xFF5C6270),
    textDisabled: Color(0xFFA7ACB8),
    success: Color(0xFF34D399),
    warning: Color(0xFFB07C09),
    error: Color(0xFFC0392B),
  );

  static const ocean = ForgePalette(
    id: ForgeThemeId.ocean,
    brightness: Brightness.dark,
    background: Color(0xFF06121F),
    surface: Color(0xFF0C1F30),
    surfaceElevated: Color(0xFF123044),
    border: Color(0xFF1E4258),
    primary: Color(0xFF0EA5E9),
    primaryVariant: Color(0xFF38BDF8),
    accent: Color(0xFF2DD4BF),
    textPrimary: Color(0xFFE6F6FB),
    textSecondary: Color(0xFF8FB4C4),
    textDisabled: Color(0xFF4A6572),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
  );

  static const forest = ForgePalette(
    id: ForgeThemeId.forest,
    brightness: Brightness.dark,
    background: Color(0xFF0D140F),
    surface: Color(0xFF16211A),
    surfaceElevated: Color(0xFF1E2E23),
    border: Color(0xFF2C4030),
    primary: Color(0xFF4CAF6D),
    primaryVariant: Color(0xFF6FCB8E),
    accent: Color(0xFFB7C948),
    textPrimary: Color(0xFFEAF2EC),
    textSecondary: Color(0xFF9CB3A3),
    textDisabled: Color(0xFF56695D),
    success: Color(0xFF66D48C),
    warning: Color(0xFFE2B93B),
    error: Color(0xFFE2725B),
  );

  static const purple = ForgePalette(
    id: ForgeThemeId.purple,
    brightness: Brightness.dark,
    background: Color(0xFF140B22),
    surface: Color(0xFF1F1233),
    surfaceElevated: Color(0xFF2B1A47),
    border: Color(0xFF3E2A5E),
    primary: Color(0xFF9B5DE5),
    primaryVariant: Color(0xFFC084FC),
    accent: Color(0xFFF15BB5),
    textPrimary: Color(0xFFF3EAFB),
    textSecondary: Color(0xFFB79CD1),
    textDisabled: Color(0xFF6B5885),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
  );

  static const minimal = ForgePalette(
    id: ForgeThemeId.minimal,
    brightness: Brightness.light,
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFAFAFA),
    surfaceElevated: Color(0xFFF2F2F2),
    border: Color(0xFFE0E0E0),
    primary: Color(0xFF111111),
    primaryVariant: Color(0xFF333333),
    accent: Color(0xFF6B6B6B),
    textPrimary: Color(0xFF111111),
    textSecondary: Color(0xFF6B6B6B),
    textDisabled: Color(0xFFB0B0B0),
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    error: Color(0xFFD32F2F),
  );

  static const cyberpunk = ForgePalette(
    id: ForgeThemeId.cyberpunk,
    brightness: Brightness.dark,
    background: Color(0xFF0A0014),
    surface: Color(0xFF150022),
    surfaceElevated: Color(0xFF200A33),
    border: Color(0xFF3A1050),
    primary: Color(0xFFFF2079),
    primaryVariant: Color(0xFFFF5FA2),
    accent: Color(0xFFF9F002),
    textPrimary: Color(0xFFF5F0FF),
    textSecondary: Color(0xFFC9A8E0),
    textDisabled: Color(0xFF5E4A73),
    success: Color(0xFF00FFA3),
    warning: Color(0xFFF9F002),
    error: Color(0xFFFF3860),
  );

  static const neon = ForgePalette(
    id: ForgeThemeId.neon,
    brightness: Brightness.dark,
    background: Color(0xFF050505),
    surface: Color(0xFF0F0F0F),
    surfaceElevated: Color(0xFF181818),
    border: Color(0xFF262626),
    primary: Color(0xFF39FF14),
    primaryVariant: Color(0xFF7CFF5B),
    accent: Color(0xFF00F0FF),
    textPrimary: Color(0xFFF2FFF0),
    textSecondary: Color(0xFF7A9E86),
    textDisabled: Color(0xFF3D4A3F),
    success: Color(0xFF39FF14),
    warning: Color(0xFFFFEE00),
    error: Color(0xFFFF073A),
  );

  static const List<ForgePalette> all = [
    dark,
    light,
    amoled,
    glass,
    ocean,
    forest,
    purple,
    minimal,
    cyberpunk,
    neon,
  ];

  static ForgePalette byId(ForgeThemeId id) => all.firstWhere((p) => p.id == id);
}
