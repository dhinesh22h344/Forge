import 'package:flutter/material.dart';
import 'forge_page_transitions.dart';
import 'forge_palette.dart';

/// Builds a [ThemeData] from a [ForgePalette] token set. Every theme (Dark,
/// Light, AMOLED, Glass, Ocean, Forest, Purple, Minimal, Cyberpunk, Neon, or
/// any of those with a custom accent) goes through this one builder, so
/// adding a theme means adding a palette in `forge_palette.dart`, not
/// touching every screen.
class AppTheme {
  const AppTheme._();

  static ThemeData build(ForgePalette palette) {
    final base = ThemeData(brightness: palette.brightness, useMaterial3: true);
    final colorScheme = base.colorScheme.copyWith(
      brightness: palette.brightness,
      primary: palette.primary,
      secondary: palette.accent,
      surface: palette.surface,
      error: palette.error,
      onPrimary: Colors.white,
      onSurface: palette.textPrimary,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      pageTransitionsTheme: forgePageTransitionsTheme,
      textTheme: _textTheme(
        base.textTheme,
        palette.textPrimary,
        palette.textSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: palette.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: palette.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        hintStyle: TextStyle(color: palette.textSecondary),
      ),
      dividerTheme: DividerThemeData(color: palette.border, thickness: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      // AppShell uses the Material 3 NavigationBar, not
      // BottomNavigationBar — this is the theme that actually reaches it.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.primary.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : palette.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : palette.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color primary, Color secondary) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: primary),
      bodyMedium: base.bodyMedium?.copyWith(color: secondary),
      labelLarge: base.labelLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
