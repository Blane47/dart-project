import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'gradient_bloom.dart';

/// The app's signature page backdrop: the near-black canvas with a single
/// atmospheric bloom drifting in from a corner. Used on full-screen surfaces
/// (auth, onboarding) to carry the brand without competing with content.
class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.bloomAlignment = const Alignment(-0.8, -0.9),
    this.bloomSize = 420,
  });

  final Widget child;
  final Alignment bloomAlignment;
  final double bloomSize;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        children: [
          Align(
            alignment: bloomAlignment,
            child: GradientBloom(size: bloomSize),
          ),
          child,
        ],
      ),
    );
  }
}
