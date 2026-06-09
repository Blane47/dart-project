import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/models.dart';
import '../../shared/services/services.dart';
import '../../shared/strings.dart';
import '../../shared/theme/theme.dart';
import '../../shared/utils/currency.dart';
import '../../shared/widgets/widgets.dart';

const _terms = [3, 6, 12];
const _employmentOptions = ['Employed', 'Self-employed', 'Student', 'Other'];
const _purposeOptions = ['Personal', 'Education', 'Business', 'Emergency'];

/// Loans. Shows an active loan with repayment, or a loan application form with a
/// live eligibility preview computed from the form + the user's account data.
class LoanScreen extends ConsumerStatefulWidget {
  const LoanScreen({super.key});

  @override
  ConsumerState<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends ConsumerState<LoanScreen> {
  final _amount = TextEditingController();
  final _income = TextEditingController();
  int _term = 6;
  String _employment = _employmentOptions.first;
  String _purpose = _purposeOptions.first;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _amount.addListener(_onChange);
    _income.addListener(_onChange);
  }

  @override
  void dispose() {
    _amount.dispose();
    _income.dispose();
    super.dispose();
  }

  void _onChange() => setState(() {});

  double get _amountValue =>
      double.tryParse(_amount.text.trim().replaceAll(',', '')) ?? 0;
  double get _incomeValue =>
      double.tryParse(_income.text.trim().replaceAll(',', '')) ?? 0;

  Future<void> _apply({
    required String uid,
    required double totalDeposited,
    required double balance,
    required int accountAgeDays,
    required bool hasActiveLoan,
  }) async {
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      final decision = await ref
          .read(firestoreServiceProvider)
          .applyForLoan(
            uid: uid,
            requestedAmount: _amountValue,
            termMonths: _term,
            monthlyIncome: _incomeValue,
            employmentStatus: _employment,
            purpose: _purpose,
            totalDeposited: totalDeposited,
            currentBalance: balance,
            accountAgeDays: accountAgeDays,
            hasActiveLoan: hasActiveLoan,
          );
      if (!mounted) return;
      if (decision.approved) {
        _amount.clear();
        showAppSnackBar(
          context,
          AppStrings.loanApprovedBody(
            formatXaf(decision.amount, withCode: true),
          ),
        );
      } else {
        showAppSnackBar(
          context,
          decision.reason ?? AppStrings.genericError,
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        showAppSnackBar(context, AppStrings.genericError, isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _repay(String uid, Loan loan) async {
    final amount = await _promptAmount(context, AppStrings.makePayment);
    if (amount == null) return;
    try {
      await ref
          .read(firestoreServiceProvider)
          .repayLoan(uid: uid, loanId: loan.id, amount: amount);
    } on BankingException catch (e) {
      if (mounted) showAppSnackBar(context, e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final uid = user.uid;
    final loans = ref.watch(loansStreamProvider(uid)).value ?? const [];
    final balance = ref.watch(balanceStreamProvider(uid)).value ?? 0;
    final txs = ref.watch(transactionsStreamProvider(uid)).value ?? const [];
    final profile = ref.watch(profileStreamProvider(uid)).value;

    Loan? active;
    for (final l in loans) {
      if (l.isActive) {
        active = l;
        break;
      }
    }

    final totalDeposited = txs
        .where((t) => t.type == TransactionType.deposit)
        .fold<double>(0, (s, t) => s + t.amount);
    final accountAgeDays = profile?.createdAt == null
        ? 0
        : DateTime.now().difference(profile!.createdAt!).inDays;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.loans)),
      body: SafeArea(
        child: active != null
            ? _ActiveLoan(loan: active, onRepay: () => _repay(uid, active!))
            : _buildForm(
                uid: uid,
                totalDeposited: totalDeposited,
                balance: balance,
                accountAgeDays: accountAgeDays,
              ),
      ),
    );
  }

  Widget _buildForm({
    required String uid,
    required double totalDeposited,
    required double balance,
    required int accountAgeDays,
  }) {
    final preview = evaluateLoan(
      requestedAmount: _amountValue,
      termMonths: _term,
      monthlyIncome: _incomeValue,
      totalDeposited: totalDeposited,
      currentBalance: balance,
      accountAgeDays: accountAgeDays,
      hasActiveLoan: false,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.loanIntro, style: AppTextStyles.bodySecondary),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: '${AppStrings.loanAmountLabel} (${AppStrings.currencyCode})',
            hint: '0',
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.account_balance_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(AppStrings.termLabel, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (final t in _terms) ...[
                Expanded(
                  child: _Pill(
                    label: AppStrings.termMonths(t),
                    selected: _term == t,
                    onTap: () => setState(() => _term = t),
                  ),
                ),
                if (t != _terms.last) const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label:
                '${AppStrings.monthlyIncomeLabel} (${AppStrings.currencyCode})',
            hint: '0',
            controller: _income,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            prefixIcon: Icons.work_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          _Dropdown(
            label: AppStrings.employmentLabel,
            value: _employment,
            options: _employmentOptions,
            onChanged: (v) => setState(() => _employment = v),
          ),
          const SizedBox(height: AppSpacing.md),
          _Dropdown(
            label: AppStrings.purposeLabel,
            value: _purpose,
            options: _purposeOptions,
            onChanged: (v) => setState(() => _purpose = v),
          ),
          const SizedBox(height: AppSpacing.lg),
          _PreviewCard(preview: preview, hasAmount: _amountValue > 0),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: AppStrings.submitApplication,
            isLoading: _submitting,
            onPressed: () => _apply(
              uid: uid,
              totalDeposited: totalDeposited,
              balance: balance,
              accountAgeDays: accountAgeDays,
              hasActiveLoan: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live eligibility / pricing preview.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preview, required this.hasAmount});
  final LoanDecision preview;
  final bool hasAmount;

  @override
  Widget build(BuildContext context) {
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
              const Icon(
                Icons.verified_user_outlined,
                size: 18,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  AppStrings.youQualifyUpTo(
                    formatXaf(preview.maxEligible, withCode: true),
                  ),
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${AppStrings.creditScoreLabel}: ${preview.creditScore}/100',
            style: AppTextStyles.caption,
          ),
          if (hasAmount && preview.approved) ...[
            const Divider(),
            _row(
              AppStrings.rateLabel,
              '${preview.ratePct.toStringAsFixed(0)}%',
            ),
            _row(
              AppStrings.estMonthly,
              formatXaf(preview.monthlyPayment, withCode: true),
            ),
            _row(
              AppStrings.totalRepayableLabel,
              formatXaf(preview.totalRepayable, withCode: true),
            ),
          ] else if (hasAmount && preview.reason != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              preview.reason!,
              style: AppTextStyles.caption.copyWith(color: AppColors.warning),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySecondary),
        Text(value, style: AppTextStyles.amount),
      ],
    ),
  );
}

class _ActiveLoan extends StatelessWidget {
  const _ActiveLoan({required this.loan, required this.onRepay});
  final Loan loan;
  final VoidCallback onRepay;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.glassBorder, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.activeLoanTitle, style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppStrings.outstandingLabel,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                BalanceText(amount: loan.outstanding),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: LinearProgressIndicator(
                    value: loan.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _row(
                  AppStrings.monthlyPaymentLabel,
                  formatXaf(loan.monthlyPayment, withCode: true),
                ),
                _row(
                  '${AppStrings.rateLabel} • ${loan.purpose}',
                  '${loan.ratePct.toStringAsFixed(0)}%',
                ),
                _row(
                  AppStrings.totalRepayableLabel,
                  formatXaf(loan.totalRepayable, withCode: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: AppStrings.repay, onPressed: onRepay),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodySecondary),
        Text(value, style: AppTextStyles.amount),
      ],
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.short,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            color: selected ? AppColors.onAccent : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xxs,
            bottom: AppSpacing.xs,
          ),
          child: Text(label, style: AppTextStyles.caption),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadii.md),
              style: AppTextStyles.body,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              items: [
                for (final o in options)
                  DropdownMenuItem(value: o, child: Text(o)),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
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
