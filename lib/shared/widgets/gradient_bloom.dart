import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// An atmospheric gradient bloom — the app's one signature flourish.
///
/// Two soft radial blobs (purple + pink) heavily blurred so they read as light,
/// not shapes. This is the *only* place the brand gradient appears, and it lives
/// strictly behind content. Sized and positioned by the caller (e.g. behind the
/// balance card); it never intercepts touches.
class GradientBloom extends StatelessWidget {
  const GradientBloom({super.key, this.size = 340, this.intensity = 0.45});

  /// Diameter of each blob.
  final double size;

  /// Peak opacity of the blobs (0–1). Keep it muted.
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              _Blob(
                color: AppColors.accent,
                intensity: intensity,
                alignment: Alignment.topLeft,
                size: size,
              ),
              _Blob(
                color: AppColors.accentPink,
                intensity: intensity * 0.85,
                alignment: Alignment.bottomRight,
                size: size,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.color,
    required this.intensity,
    required this.alignment,
    required this.size,
  });

  final Color color;
  final double intensity;
  final Alignment alignment;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size * 0.72,
        height: size * 0.72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: intensity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
