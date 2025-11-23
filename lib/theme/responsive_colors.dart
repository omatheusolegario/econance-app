import 'package:flutter/material.dart';

/// Small helper functions to map hard-coded `Colors.*` usages
/// to theme-aware equivalents. Use these to keep the app responsive
/// to light/dark theme without changing the visual palette.
class ResponsiveColors {
  static Color onBackground(ThemeData theme) => theme.colorScheme.onBackground;

  static Color onPrimary(ThemeData theme) => theme.colorScheme.onPrimary;

  static Color hint(ThemeData theme) {
    // Prefer theme.hintColor for hint/secondary text.
    return theme.hintColor;
  }

  static Color divider(ThemeData theme) => theme.dividerColor;

  static Color error(ThemeData theme) => theme.colorScheme.error;

  static Color success(ThemeData theme) => theme.colorScheme.primary;

  // Chart-specific vivid colors (keep these strong, not pastel).
  static Color chartRevenue(ThemeData theme) => const Color(0xFF2E7D32); // strong green
  static Color chartExpense(ThemeData theme) => const Color(0xFFD32F2F); // strong red
  static Color chartInvestment(ThemeData theme) => const Color(0xFF6A1B9A); // strong purple
  static Color chartBalance(ThemeData theme) => const Color(0xFF1565C0); // strong blue

  static Color whiteOpacity(ThemeData theme, double opacity) =>
      theme.colorScheme.onBackground.withOpacity(opacity);

  static Color greyShade(ThemeData theme, int shade) {
    // best-effort mapping of common grey shades to theme-aware colors.
    if (theme.brightness == Brightness.dark) {
      return Colors.grey[800]!;
    }
    return Colors.grey[300]!;
  }

  static Color transparent() => Colors.transparent;
}
