import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A frosted-glass card: real backdrop blur, a translucent fill, a lit hairline
/// rim, and a soft containment shadow.
///
/// Per agave, a card uses *one* containment treatment — here the shadow does the
/// lifting and the hairline only defines the glass edge. Reserve this for
/// grouped content that benefits from containment (e.g. the balance card); a
/// lone hero number should float on the background instead.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadii.lg,
    this.blur = 18,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: borderRadius,
              border: Border.all(color: AppColors.glassBorder, width: 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
