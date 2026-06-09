import 'package:flutter/material.dart';

import '../../../shared/models/models.dart';
import '../../../shared/theme/theme.dart';
import '../../../shared/utils/currency.dart';

/// One ledger row: a direction icon, the description + timestamp, and the signed
/// amount (deposits in success-green, withdrawals neutral). Shared by the
/// dashboard's recent list and the full transactions screen.
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final BankTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isDeposit = transaction.type == TransactionType.deposit;
    final color = isDeposit ? AppColors.success : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isDeposit ? AppColors.success : AppColors.textSecondary)
                  .withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDeposit ? Icons.south_west_rounded : Icons.north_east_rounded,
              size: 20,
              color: isDeposit ? AppColors.success : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${isDeposit ? '+' : '-'}${formatXaf(transaction.amount)}',
            style: AppTextStyles.amount.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final days = today.difference(that).inDays;
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    if (days == 0) return 'Today · $time';
    if (days == 1) return 'Yesterday · $time';
    return '${d.day} ${_months[d.month - 1]} · $time';
  }
}
