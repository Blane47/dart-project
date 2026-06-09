import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../shared/models/models.dart';
import '../../../shared/strings.dart';
import '../../../shared/theme/theme.dart';

/// The card artwork. Tap to flip between the front (masked number) and back
/// (full number + CVV). This is the one surface where the brand purple→pink
/// gradient belongs — a credit-card face. Honours reduce-motion by snapping.
class CardVisual extends StatefulWidget {
  const CardVisual({super.key, required this.card, this.revealed = false});

  final VirtualCard card;
  final bool revealed;

  @override
  State<CardVisual> createState() => _CardVisualState();
}

class _CardVisualState extends State<CardVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppDurations.medium,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _flip() {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final target = _c.value >= 0.5 ? 0.0 : 1.0;
    if (reduceMotion) {
      _c.value = target;
    } else {
      _c.animateTo(target, curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final angle = _c.value * math.pi;
          final isBack = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardBack(card: widget.card),
                  )
                : _CardFront(card: widget.card),
          );
        },
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child, required this.frozen});
  final Widget child;
  final bool frozen;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586, // ISO/IEC 7810 ID-1 card ratio
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: frozen
                ? [AppColors.surfaceElevated, AppColors.surface]
                : [AppColors.accent, AppColors.accentPink],
          ),
          boxShadow: AppShadows.card,
        ),
        child: child,
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({required this.card});
  final VirtualCard card;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      frozen: card.frozen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.appName.toUpperCase(),
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.onAccent,
                  letterSpacing: 2,
                ),
              ),
              if (card.frozen)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    AppStrings.frozenLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.onAccent,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.contactless_rounded,
                  color: AppColors.onAccent,
                ),
            ],
          ),
          const Spacer(),
          // Chip
          Container(
            width: 38,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.onAccent.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            card.masked,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.onAccent,
              letterSpacing: 2,
              fontFeatures: const [],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  card.holder,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onAccent,
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                card.expiry,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.card});
  final VirtualCard card;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      frozen: card.frozen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xs),
          // Magnetic stripe
          Container(
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: -AppSpacing.lg),
            color: AppColors.background.withValues(alpha: 0.85),
          ),
          const Spacer(),
          Text(
            card.formatted,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.onAccent,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                'CVV ',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onAccent.withValues(alpha: 0.8),
                ),
              ),
              Text(
                card.cvv,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.onAccent,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            AppStrings.tapToReveal,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onAccent.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
