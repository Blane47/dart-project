import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Inter-based type scale.
///
/// Restraint is the rule: only ONE extreme size exists — [balanceHero]. Every
/// other style stays in a calm 13–28px band so the hero number always wins the
/// eye. Numbers use tabular figures so digits never shift width as they change.
abstract final class AppTextStyles {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// The single largest element in the app — the balance number.
  static TextStyle get balanceHero => GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      height: 1.0,
      letterSpacing: -1.5,
      color: AppColors.textPrimary,
      fontFeatures: _tabular,
    ),
  );

  /// Small companion for the balance — currency code, symbol.
  static TextStyle get balanceUnit => GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.0,
      letterSpacing: 0.5,
      color: AppColors.textSecondary,
    ),
  );

  /// Screen / section headings.
  static TextStyle get heading => GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.5,
      color: AppColors.textPrimary,
    ),
  );

  static TextStyle get titleLarge => GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: AppColors.textPrimary,
    ),
  );

  static TextStyle get titleMedium => GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textPrimary,
    ),
  );

  /// Monetary amounts in lists / rows.
  static TextStyle get amount => GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textPrimary,
      fontFeatures: _tabular,
    ),
  );

  static TextStyle get body => GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textPrimary,
    ),
  );

  static TextStyle get bodySecondary => GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textSecondary,
    ),
  );

  /// Button / action labels.
  static TextStyle get label => GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.2,
      color: AppColors.onAccent,
    ),
  );

  static TextStyle get caption => GoogleFonts.inter(
    textStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.3,
      letterSpacing: 0.2,
      color: AppColors.textSecondary,
    ),
  );

  /// Full Inter [TextTheme] for the Material base, with dark-mode text colours.
  static TextTheme get textTheme => GoogleFonts.interTextTheme().apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );
}
