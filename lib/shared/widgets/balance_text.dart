import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/theme.dart';
import '../utils/currency.dart';

/// The hero balance display.
///
/// Mixed-size metric: the amount is the focal point (56px, tabular figures),
/// while the currency code stays small and recedes — context the user already
/// expects. XAF has no minor unit, so the amount is whole. Toggling [hidden]
/// cross-fades between the number and a masked placeholder; the fade is short
/// and subtle because hiding a balance is an occasional, deliberate action.
class BalanceText extends StatelessWidget {
  const BalanceText({
    super.key,
    required this.amount,
    this.currencyCode = AppStrings.currencyCode,
    this.hidden = false,
  });

  final double amount;
  final String currencyCode;
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppDurations.short,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      // Key on visibility so the switcher animates only the show/hide toggle,
      // not every amount change.
      child: hidden
          ? _Masked(key: const ValueKey('hidden'), currencyCode: currencyCode)
          : _Amount(
              key: const ValueKey('shown'),
              amount: amount,
              currencyCode: currencyCode,
            ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({super.key, required this.amount, required this.currencyCode});

  final double amount;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            formatXaf(amount),
            style: AppTextStyles.balanceHero,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(currencyCode, style: AppTextStyles.balanceUnit),
        ),
      ],
    );
  }
}

class _Masked extends StatelessWidget {
  const _Masked({super.key, required this.currencyCode});

  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('••••••', style: AppTextStyles.balanceHero),
        const SizedBox(width: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Text(currencyCode, style: AppTextStyles.balanceUnit),
        ),
      ],
    );
  }
}
