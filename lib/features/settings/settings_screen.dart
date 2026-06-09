import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/services/services.dart';
import '../../shared/strings.dart';
import '../../shared/theme/theme.dart';

/// Settings: account summary, the hide-balance preference, and sign out.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.6),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        title: Text(
          AppStrings.signOutConfirmTitle,
          style: AppTextStyles.titleMedium,
        ),
        content: Text(
          AppStrings.signOutConfirmBody,
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.signOut),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      // Router redirect sends us back to sign-in once the stream clears.
      await ref.read(firebaseAuthServiceProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profile = user == null
        ? null
        : ref.watch(profileStreamProvider(user.uid)).value;
    final name = profile?.displayName?.trim();
    final email = profile?.email ?? user?.email ?? '';
    final hidden = ref.watch(balanceHiddenProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _AccountCard(
              name: (name == null || name.isEmpty) ? AppStrings.appName : name,
              email: email,
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionLabel(AppStrings.preferences),
            const SizedBox(height: AppSpacing.xs),
            _SettingCard(
              child: SwitchListTile(
                value: hidden,
                onChanged: (v) =>
                    ref.read(balanceHiddenProvider.notifier).set(v),
                activeThumbColor: AppColors.accent,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  AppStrings.hideBalanceByDefault,
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionLabel(AppStrings.account),
            const SizedBox(height: AppSpacing.xs),
            _SettingCard(
              child: ListTile(
                onTap: () => _confirmSignOut(context, ref),
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                ),
                title: Text(
                  AppStrings.signOut,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.name, required this.email});
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return _SettingCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xxs),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.caption.copyWith(letterSpacing: 1),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: child,
    );
  }
}
