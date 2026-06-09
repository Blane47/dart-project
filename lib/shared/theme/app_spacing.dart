import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 8px-based spacing scale. Use these everywhere — no magic numbers.
/// Internal padding should always be smaller than the gap between siblings.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
}

/// Corner radii. Cards use [lg]. Follow the nested-radius rule: an inner
/// element's radius = outer radius − the padding between them.
abstract final class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 999;
}

/// Motion durations, mapped to interaction frequency.
/// Frequent taps stay fast; rarer layout changes can breathe a little.
abstract final class AppDurations {
  /// Taps, toggles, presses — high frequency, must feel instant.
  static const Duration micro = Duration(milliseconds: 120);

  /// Content swaps — tab/label changes, fades.
  static const Duration short = Duration(milliseconds: 220);

  /// Layout changes — sheets, page-level moments.
  static const Duration medium = Duration(milliseconds: 320);
}

/// Elevation. On a near-black canvas, depth comes from soft layered shadows
/// (ambient + directional) and, for hero elements, a tinted accent glow.
abstract final class AppShadows {
  /// Soft containment shadow for cards. Prefer this over a border.
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x40000000), blurRadius: 28, offset: Offset(0, 14)),
    BoxShadow(color: Color(0x1F000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  /// Purple glow beneath the primary action / balance card.
  static List<BoxShadow> accentGlow({double opacity = 0.35}) => [
    BoxShadow(
      color: AppColors.accent.withValues(alpha: opacity),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: -8,
    ),
  ];
}
