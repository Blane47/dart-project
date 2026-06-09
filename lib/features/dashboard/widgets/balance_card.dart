import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/services.dart';
import '../../../shared/strings.dart';
import '../../../shared/theme/theme.dart';
import '../../../shared/widgets/widgets.dart';

/// The hero of the dashboard: the live balance on a frosted card with the
/// atmospheric bloom glowing behind it, plus the hide/show toggle.
class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(balanceStreamProvider(uid));
    final hidden = ref.watch(balanceHiddenProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(top: -34, left: -10, child: const GradientBloom(size: 320)),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.availableBalance,
                    style: AppTextStyles.caption,
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(balanceHiddenProvider.notifier).toggle(),
                    visualDensity: VisualDensity.compact,
                    tooltip: hidden
                        ? AppStrings.showBalance
                        : AppStrings.hideBalance,
                    icon: Icon(
                      hidden
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              balance.when(
                data: (value) => BalanceText(amount: value, hidden: hidden),
                loading: () => const _BalanceSkeleton(),
                error: (_, _) => Text('—', style: AppTextStyles.balanceHero),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceSkeleton extends StatelessWidget {
  const _BalanceSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
    );
  }
}
