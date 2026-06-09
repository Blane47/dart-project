import 'package:flutter/material.dart';

/// Colour tokens for the app.
///
/// Dark-mode-first fintech palette. Every colour here is *functional*:
/// surfaces, text hierarchy, the single brand accent, semantic states, and the
/// atmospheric gradient reserved for hero metrics. Nothing decorative lives
/// here — if a colour can't justify its role, it doesn't belong.
abstract final class AppColors {
  // ---- Surfaces (darkest -> lightest) ----
  /// App background — the base canvas everything sits on.
  static const Color background = Color(0xFF0A0A0F);

  /// Default card / sheet surface.
  static const Color surface = Color(0xFF1A1A24);

  /// Slightly raised surface for nested or elevated elements.
  static const Color surfaceElevated = Color(0xFF24242F);

  // ---- Brand accent ----
  /// Primary brand + primary action colour (electric purple).
  static const Color accent = Color(0xFF7C3AED);

  /// Pressed / active variant of the accent.
  static const Color accentPressed = Color(0xFF6D28D9);

  /// Second stop of the atmospheric gradient bloom (pink).
  /// Used ONLY in background blooms — never on controls.
  static const Color accentPink = Color(0xFFEC4899);

  // ---- Text hierarchy ----
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textTertiary = Color(0xFF6B7280);

  /// Text / icon that sits on top of the accent fill.
  static const Color onAccent = Color(0xFFFFFFFF);

  // ---- Semantic states ----
  /// Money in / positive / success.
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFF43F5E);
  static const Color warning = Color(0xFFF59E0B);

  // ---- Glass + hairlines (prefer shadows over borders elsewhere) ----
  /// Translucent fill behind a blurred glass card.
  static const Color glassFill = Color.fromRGBO(255, 255, 255, 0.06);

  /// Hairline edge that gives a glass card its lit rim.
  static const Color glassBorder = Color.fromRGBO(255, 255, 255, 0.10);
}
