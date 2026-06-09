import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/models.dart';
import '../../shared/services/services.dart';
import '../../shared/strings.dart';
import '../../shared/theme/theme.dart';
import '../../shared/utils/currency.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/card_visual.dart';

/// Virtual card: a (simulated) card for online payments. Create one, reveal its
/// details by tapping, freeze/unfreeze it, and make simulated online payments
/// that debit the balance and appear in the ledger.
class CardScreen extends ConsumerWidget {
  const CardScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref, String uid) async {
    final profile = ref.read(profileStreamProvider(uid)).value;
    final holder = (profile?.displayName?.trim().isNotEmpty ?? false)
        ? profile!.displayName!.trim()
        : 'Vault User';
    try {
      await ref
          .read(firestoreServiceProvider)
          .createCard(uid: uid, holder: holder);
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(context, AppStrings.genericError, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final cards = user == null
        ? const AsyncValue<List<VirtualCard>>.loading()
        : ref.watch(cardsStreamProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.virtualCard)),
      body: SafeArea(
        child: cards.when(
          data: (items) {
            if (items.isEmpty) {
              return EmptyState(
                icon: Icons.credit_card_off_rounded,
                title: AppStrings.noCardTitle,
                message: AppStrings.noCardBody,
                action: PrimaryButton(
                  label: AppStrings.createCard,
                  icon: Icons.add_rounded,
                  expand: false,
                  onPressed: () => _create(context, ref, user!.uid),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xl),
              itemBuilder: (_, i) => _CardItem(uid: user!.uid, card: items[i]),
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

class _CardItem extends ConsumerWidget {
  const _CardItem({required this.uid, required this.card});
  final String uid;
  final VirtualCard card;

  Future<void> _pay(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({String merchant, double amount})>(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.6),
      builder: (_) => const _PayDialog(),
    );
    if (result == null) return;
    try {
      await ref
          .read(firestoreServiceProvider)
          .payWithCard(
            uid: uid,
            cardId: card.id,
            merchant: result.merchant,
            amount: result.amount,
          );
      if (context.mounted) {
        showAppSnackBar(
          context,
          AppStrings.paymentSuccess(
            formatXaf(result.amount, withCode: true),
            result.merchant,
          ),
        );
      }
    } on BankingException catch (e) {
      if (context.mounted) showAppSnackBar(context, e.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(firestoreServiceProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CardVisual(card: card),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: Text(AppStrings.tapToReveal, style: AppTextStyles.caption),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: card.frozen
                    ? Icons.lock_open_rounded
                    : Icons.ac_unit_rounded,
                label: card.frozen ? AppStrings.unfreeze : AppStrings.freeze,
                onTap: () => service.setCardFrozen(
                  uid: uid,
                  cardId: card.id,
                  frozen: !card.frozen,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _ActionButton(
                icon: Icons.shopping_bag_rounded,
                label: AppStrings.payOnline,
                onTap: () => _pay(context, ref),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TextButton.icon(
          onPressed: () => service.deleteCard(uid: uid, cardId: card.id),
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          label: const Text(AppStrings.deleteCard),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.xs),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayDialog extends StatefulWidget {
  const _PayDialog();

  @override
  State<_PayDialog> createState() => _PayDialogState();
}

class _PayDialogState extends State<_PayDialog> {
  final _merchant = TextEditingController();
  final _amount = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    final merchant = _merchant.text.trim();
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', ''));
    if (merchant.isEmpty) {
      setState(() => _error = 'Enter a merchant.');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _error = AppStrings.errAmountInvalid);
      return;
    }
    Navigator.of(context).pop((merchant: merchant, amount: amount));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      title: Text(AppStrings.payOnline, style: AppTextStyles.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: AppStrings.merchantLabel,
            hint: AppStrings.merchantHint,
            controller: _merchant,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: '${AppStrings.amountLabel} (${AppStrings.currencyCode})',
            hint: '0',
            controller: _amount,
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
        TextButton(onPressed: _submit, child: const Text(AppStrings.pay)),
      ],
    );
  }
}
