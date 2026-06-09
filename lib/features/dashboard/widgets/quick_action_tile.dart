import 'package:flutter/material.dart';

import '../../../shared/theme/theme.dart';

/// A single quick-action: icon over label, with a fast press-scale. The
/// `primary` variant fills with the accent (the dashboard's main action,
/// Deposit); the rest are quiet glass tiles so one action clearly leads.
class QuickActionTile extends StatefulWidget {
  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final fg = widget.primary ? AppColors.onAccent : AppColors.textPrimary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: (_pressed && !reduceMotion) ? 0.96 : 1.0,
          duration: AppDurations.micro,
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: widget.primary ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: widget.primary
                  ? null
                  : Border.all(color: AppColors.glassBorder, width: 1),
              boxShadow: widget.primary ? AppShadows.accentGlow() : null,
            ),
            child: Column(
              children: [
                Icon(widget.icon, color: fg, size: 24),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.label,
                  style: AppTextStyles.caption.copyWith(color: fg),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
