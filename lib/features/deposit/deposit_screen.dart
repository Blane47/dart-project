import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/services/services.dart';
import '../../shared/strings.dart';
import '../../shared/theme/theme.dart';
import '../../shared/utils/currency.dart';
import '../../shared/utils/validators.dart';
import '../../shared/widgets/widgets.dart';

/// Simulated deposit. Validates an amount, writes it through the atomic
/// `recordDeposit`, then swaps the form for a success state with a one-shot
/// checkmark animation (a deposit is rare, so the delight is warranted).
class DepositScreen extends ConsumerStatefulWidget {
  const DepositScreen({super.key});

  @override
  ConsumerState<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends ConsumerState<DepositScreen> {
  static const List<int> _presets = [5000, 10000, 25000, 50000];

  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  bool _submitting = false;
  double? _successAmount;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    FocusScope.of(context).unfocus();

    final value = double.parse(_amount.text.trim().replaceAll(',', ''));
    setState(() => _submitting = true);
    try {
      await ref
          .read(firestoreServiceProvider)
          .recordDeposit(uid: user.uid, amount: value);
      if (mounted) setState(() => _successAmount = value);
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, AppStrings.genericError, isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.depositTitle)),
      body: SafeArea(
        child: _successAmount != null
            ? _DepositSuccess(amount: _successAmount!)
            : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.depositSubtitle,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: '${AppStrings.amountLabel} (${AppStrings.currencyCode})',
              hint: '0',
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.payments_outlined,
              validator: Validators.amount,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final preset in _presets)
                  _PresetChip(
                    label: formatXaf(preset),
                    onTap: () => setState(() {
                      _amount.text = preset.toString();
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: AppStrings.confirmDeposit,
              isLoading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Text(label, style: AppTextStyles.caption),
        ),
      ),
    );
  }
}

class _DepositSuccess extends StatelessWidget {
  const _DepositSuccess({required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
            duration: const Duration(milliseconds: 480),
            curve: Curves.easeOutBack,
            builder: (context, t, child) => Transform.scale(
              scale: t,
              child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
            ),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 48,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppStrings.depositSuccessTitle,
            style: AppTextStyles.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.depositSuccessBody(formatXaf(amount, withCode: true)),
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: AppStrings.backToDashboard,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
