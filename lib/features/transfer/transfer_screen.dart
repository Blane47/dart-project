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

/// Peer-to-peer transfer: send money to another Vault user by email. The move
/// is one atomic Firestore transaction (debit sender, credit recipient, two
/// ledger entries) in [FirestoreService.transfer].
class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _amount = TextEditingController();
  bool _submitting = false;
  ({String email, double amount})? _success;

  @override
  void dispose() {
    _email.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    FocusScope.of(context).unfocus();

    final firestore = ref.read(firestoreServiceProvider);
    final email = _email.text.trim();
    final amount = double.parse(_amount.text.trim().replaceAll(',', ''));

    setState(() => _submitting = true);
    try {
      await firestore.transfer(
        fromUid: user.uid,
        toEmail: email,
        amount: amount,
      );
      if (mounted) setState(() => _success = (email: email, amount: amount));
    } on BankingException catch (e) {
      if (mounted) showAppSnackBar(context, e.message, isError: true);
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
      appBar: AppBar(title: const Text(AppStrings.transferTitle)),
      body: SafeArea(
        child: _success != null
            ? _TransferSuccess(email: _success!.email, amount: _success!.amount)
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
              AppStrings.transferSubtitle,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: AppStrings.recipientEmailLabel,
              hint: AppStrings.emailHint,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.alternate_email_rounded,
              validator: Validators.email,
            ),
            const SizedBox(height: AppSpacing.md),
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
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: AppStrings.sendMoney,
              icon: Icons.send_rounded,
              isLoading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferSuccess extends StatelessWidget {
  const _TransferSuccess({required this.email, required this.amount});

  final String email;
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
                Icons.send_rounded,
                size: 40,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppStrings.transferSuccessTitle,
            style: AppTextStyles.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.transferSuccessBody(
              formatXaf(amount, withCode: true),
              email,
            ),
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
