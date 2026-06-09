import 'package:flutter/material.dart';

import '../../../shared/strings.dart';
import '../../../shared/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

/// Shared chrome for the auth screens: the signature bloom background, an
/// optional back button, the app wordmark, and a title/subtitle block above the
/// screen's form. Keeps the three auth screens visually identical.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: showBack
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: AppColors.textPrimary,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              )
            : null,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(title, style: AppTextStyles.heading),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: AppTextStyles.bodySecondary),
                const SizedBox(height: AppSpacing.xl),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A right-aligned "prompt + action" footer row, e.g.
/// "Don't have an account? Create account".
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: AppTextStyles.bodySecondary),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}
