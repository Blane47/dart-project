import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/models.dart';
import '../../shared/services/services.dart';
import '../../shared/strings.dart';
import '../../shared/theme/theme.dart';
import '../../shared/utils/currency.dart';
import '../../shared/widgets/widgets.dart';

/// Savings goals ("pots"). Money added to a goal is debited from the main
/// balance via an atomic transaction, so totals always reconcile.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref, String uid) async {
    final result = await showDialog<({String name, double target})>(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.6),
      builder: (_) => const _CreateGoalDialog(),
    );
    if (result == null) return;
    try {
      await ref
          .read(firestoreServiceProvider)
          .createGoal(uid: uid, name: result.name, target: result.target);
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(context, AppStrings.genericError, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final goals = user == null
        ? const AsyncValue<List<SavingsGoal>>.loading()
        : ref.watch(goalsStreamProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.savingsGoals)),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _create(context, ref, user.uid),
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              icon: const Icon(Icons.add_rounded),
              label: const Text(AppStrings.newGoal),
            ),
      body: SafeArea(
        child: goals.when(
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.savings_outlined,
                title: AppStrings.goalsEmptyTitle,
                message: AppStrings.goalsEmptyBody,
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) => _GoalCard(uid: user!.uid, goal: items[i]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Text(
              AppStrings.genericError,
              style: AppTextStyles.bodySecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.uid, required this.goal});

  final String uid;
  final SavingsGoal goal;

  Future<void> _addFunds(BuildContext context, WidgetRef ref) async {
    final amount = await _promptAmount(context, AppStrings.addFunds);
    if (amount == null) return;
    try {
      await ref
          .read(firestoreServiceProvider)
          .addToGoal(uid: uid, goalId: goal.id, amount: amount);
    } on BankingException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message, isError: true);
    }
  }

  Future<void> _withdraw(BuildContext context, WidgetRef ref) async {
    final amount = await _promptAmount(context, AppStrings.withdraw);
    if (amount == null) return;
    try {
      await ref
          .read(firestoreServiceProvider)
          .withdrawFromGoal(uid: uid, goalId: goal.id, amount: amount);
    } on BankingException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message, isError: true);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(firestoreServiceProvider)
          .deleteGoal(uid: uid, goalId: goal.id);
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(context, AppStrings.genericError, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProgressRing(progress: goal.progress),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.savedOfTarget(
                        formatXaf(goal.saved),
                        formatXaf(goal.target, withCode: true),
                      ),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _delete(context, ref),
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.textTertiary,
                tooltip: AppStrings.deleteGoal,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MiniButton(
                  icon: Icons.add_rounded,
                  label: AppStrings.addFunds,
                  onTap: () => _addFunds(context, ref),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniButton(
                  icon: Icons.remove_rounded,
                  label: AppStrings.withdraw,
                  onTap: goal.saved > 0 ? () => _withdraw(context, ref) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated circular progress indicator with a centred percentage.
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: AppDurations.medium,
        curve: Curves.easeOut,
        builder: (context, value, _) => Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 5,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1 ? AppColors.success : AppColors.accent,
                ),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: AppColors.textPrimary),
                const SizedBox(width: AppSpacing.xxs),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog returning `(name, target)` for a new goal.
class _CreateGoalDialog extends StatefulWidget {
  const _CreateGoalDialog();

  @override
  State<_CreateGoalDialog> createState() => _CreateGoalDialogState();
}

class _CreateGoalDialogState extends State<_CreateGoalDialog> {
  final _name = TextEditingController();
  final _target = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final target = double.tryParse(_target.text.trim().replaceAll(',', ''));
    if (name.isEmpty) {
      setState(() => _error = AppStrings.errNameRequired);
      return;
    }
    if (target == null || target <= 0) {
      setState(() => _error = AppStrings.errAmountInvalid);
      return;
    }
    Navigator.of(context).pop((name: name, target: target));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      title: Text(AppStrings.newGoal, style: AppTextStyles.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: AppStrings.goalNameLabel,
            hint: AppStrings.goalNameHint,
            controller: _name,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label:
                '${AppStrings.targetAmountLabel} (${AppStrings.currencyCode})',
            hint: '0',
            controller: _target,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text(AppStrings.createGoal),
        ),
      ],
    );
  }
}

/// Prompts for a positive amount, returning it (or null if cancelled).
Future<double?> _promptAmount(BuildContext context, String title) {
  final controller = TextEditingController();
  return showDialog<double>(
    context: context,
    barrierColor: AppColors.background.withValues(alpha: 0.6),
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      title: Text(title, style: AppTextStyles.titleMedium),
      content: AppTextField(
        label: '${AppStrings.amountLabel} (${AppStrings.currencyCode})',
        hint: '0',
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () {
            final v = double.tryParse(
              controller.text.trim().replaceAll(',', ''),
            );
            Navigator.of(dialogContext).pop(v != null && v > 0 ? v : null);
          },
          child: const Text(AppStrings.done),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}
