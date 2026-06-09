import 'package:flutter/material.dart';

import '../../../shared/theme/theme.dart';

/// Visual state of a single answer choice after (or before) the user answers.
enum ChoiceState { idle, correct, wrong, dimmed }

/// One answer option. Before answering it's a quiet tappable tile; after, the
/// correct option turns green and a wrong pick turns red, with the rest dimmed —
/// instant, legible feedback with no ambiguity.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final ChoiceState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (
      Color border,
      Color text,
      IconData? icon,
      Color iconColor,
    ) = switch (state) {
      ChoiceState.correct => (
        AppColors.success,
        AppColors.textPrimary,
        Icons.check_circle_rounded,
        AppColors.success,
      ),
      ChoiceState.wrong => (
        AppColors.error,
        AppColors.textPrimary,
        Icons.cancel_rounded,
        AppColors.error,
      ),
      ChoiceState.dimmed => (
        AppColors.glassBorder,
        AppColors.textTertiary,
        null,
        AppColors.textTertiary,
      ),
      ChoiceState.idle => (
        AppColors.glassBorder,
        AppColors.textPrimary,
        null,
        AppColors.textSecondary,
      ),
    };

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.short,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: border, width: 1.4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(color: text),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(icon, color: iconColor, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}
