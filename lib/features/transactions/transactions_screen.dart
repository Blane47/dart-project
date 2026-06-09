import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/models.dart';
import '../../shared/services/services.dart';
import '../../shared/strings.dart';
import '../../shared/theme/theme.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/transaction_tile.dart';

enum _Filter {
  all(AppStrings.filterAll, null),
  deposits(AppStrings.filterDeposits, TransactionType.deposit),
  withdrawals(AppStrings.filterWithdrawals, TransactionType.withdrawal);

  const _Filter(this.label, this.type);
  final String label;
  final TransactionType? type;
}

/// Full transaction history with a deposits/withdrawals filter.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final txs = user == null
        ? const AsyncValue<List<BankTransaction>>.loading()
        : ref.watch(transactionsStreamProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.transactions)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: _FilterBar(
                selected: _filter,
                onChanged: (f) => setState(() => _filter = f),
              ),
            ),
            Expanded(
              child: txs.when(
                data: (items) {
                  final filtered = _filter.type == null
                      ? items
                      : items.where((t) => t.type == _filter.type).toList();
                  if (filtered.isEmpty) {
                    return const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: AppStrings.noTransactionsTitle,
                      message: AppStrings.noTransactionsBody,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) =>
                        TransactionTile(transaction: filtered[i]),
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
          ],
        ),
      ),
    );
  }
}

/// Segmented filter. The selected segment inverts to an accent fill — one clear
/// "you are here" anchor, no competing highlights.
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final _Filter selected;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        children: [
          for (final f in _Filter.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(f),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: AppDurations.short,
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: f == selected
                        ? AppColors.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    f.label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: f == selected
                          ? AppColors.onAccent
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
