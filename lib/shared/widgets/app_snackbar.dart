import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Shows a single floating snackbar, replacing any currently visible one.
/// Errors use the semantic error colour; everything else uses an elevated
/// neutral surface so it reads as a quiet confirmation, not an alarm.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodySecondary.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: isError
            ? AppColors.error.withValues(alpha: 0.95)
            : AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
}
