import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// The app's single primary action button.
///
/// Design notes:
/// - Flat accent fill (no gradient on controls — gradients are reserved for
///   background blooms). A soft accent glow gives it lift on the dark canvas.
/// - Press feedback is a fast 0.97 scale (Emil's frequency gate: buttons are
///   high-frequency, so motion is instant and unnoticed, not decorative).
/// - Loading swaps the label for a spinner via a quick cross-fade.
/// - Honours `prefers-reduced-motion` by skipping the press scale.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;

  /// Tap handler. When null the button renders disabled.
  final VoidCallback? onPressed;

  final IconData? icon;
  final bool isLoading;

  /// Whether the button stretches to fill its parent's width.
  final bool expand;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed(bool value) {
    if (!_enabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final scale = (_pressed && !reduceMotion) ? 0.97 : 1.0;

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _enabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: scale,
          duration: AppDurations.micro,
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _enabled ? 1.0 : 0.45,
            duration: AppDurations.micro,
            child: Container(
              width: widget.expand ? double.infinity : null,
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: _pressed ? AppColors.accentPressed : AppColors.accent,
                borderRadius: BorderRadius.circular(AppRadii.md),
                boxShadow: _enabled ? AppShadows.accentGlow() : null,
              ),
              child: AnimatedSwitcher(
                duration: AppDurations.short,
                child: widget.isLoading
                    ? const _ButtonSpinner()
                    : _ButtonContent(label: widget.label, icon: widget.icon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppColors.onAccent),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(label, style: AppTextStyles.label),
      ],
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.4,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.onAccent),
      ),
    );
  }
}
