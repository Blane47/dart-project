import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Builds the single dark Material 3 theme for the app.
///
/// Material is the base; agave tokens customise it. Dark mode is the primary
/// (and only) mode — the palette is tuned for a near-black canvas, not flipped
/// from a light theme.
ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.dark(
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    secondary: AppColors.accentPink,
    onSecondary: AppColors.onAccent,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.onAccent,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: AppTextStyles.textTheme,
    splashColor: AppColors.accent.withValues(alpha: 0.12),
    highlightColor: AppColors.accent.withValues(alpha: 0.06),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.glassBorder,
      thickness: 1,
      space: AppSpacing.lg,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: AppTextStyles.label.copyWith(color: AppColors.accent),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
    ),
  );
}
