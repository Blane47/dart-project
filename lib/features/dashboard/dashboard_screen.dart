import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../shared/services/services.dart';
import '../../shared/strings.dart';
import '../../shared/theme/theme.dart';
import '../../shared/widgets/widgets.dart';
import '../transactions/widgets/transaction_tile.dart';
import 'widgets/balance_card.dart';
import 'widgets/quick_action_tile.dart';

/// The signed-in home: greeting, live balance card, quick actions, and a short
/// recent-activity preview.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const int _recentCount = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final uid = user.uid;
    final profile = ref.watch(profileStreamProvider(uid));
    final name = profile.value?.displayName?.split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(name: name),
              const SizedBox(height: AppSpacing.xl),
              BalanceCard(uid: uid),
              const SizedBox(height: AppSpacing.xl),
              Text(AppStrings.quickActions, style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  QuickActionTile(
                    icon: Icons.add_rounded,
                    label: AppStrings.deposit,
                    primary: true,
                    onTap: () => context.push(AppRoutes.deposit),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  QuickActionTile(
                    icon: Icons.send_rounded,
                    label: AppStrings.transfer,
                    onTap: () => context.push(AppRoutes.transfer),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  QuickActionTile(
                    icon: Icons.savings_rounded,
                    label: AppStrings.goals,
                    onTap: () => context.push(AppRoutes.goals),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  QuickActionTile(
                    icon: Icons.show_chart_rounded,
                    label: AppStrings.insights,
                    onTap: () => context.push(AppRoutes.insights),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  QuickActionTile(
                    icon: Icons.receipt_long_rounded,
                    label: AppStrings.transactions,
                    onTap: () => context.push(AppRoutes.transactions),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  QuickActionTile(
                    icon: Icons.quiz_rounded,
                    label: AppStrings.quiz,
                    onTap: () => context.push(AppRoutes.quiz),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              _RecentActivity(uid: uid, max: _recentCount),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.name});
  final String? name;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.greetingMorning;
    if (hour < 17) return AppStrings.greetingAfternoon;
    return AppStrings.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting, style: AppTextStyles.bodySecondary),
              const SizedBox(height: 2),
              Text(
                name == null ? AppStrings.appName : name!,
                style: AppTextStyles.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined),
          color: AppColors.textSecondary,
          tooltip: AppStrings.settings,
        ),
      ],
    );
  }
}

class _RecentActivity extends ConsumerWidget {
  const _RecentActivity({required this.uid, required this.max});
  final String uid;
  final int max;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(transactionsStreamProvider(uid));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.recentActivity, style: AppTextStyles.titleLarge),
            if ((txs.value?.isNotEmpty ?? false))
              TextButton(
                onPressed: () => context.push(AppRoutes.transactions),
                child: const Text(AppStrings.seeAll),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        txs.when(
          data: (items) {
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: AppStrings.noActivityTitle,
                  message: AppStrings.noActivityBody,
                ),
              );
            }
            final visible = items.take(max).toList();
            return Column(
              children: [
                for (var i = 0; i < visible.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  TransactionTile(transaction: visible[i]),
                ],
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              AppStrings.genericError,
              style: AppTextStyles.bodySecondary,
            ),
          ),
        ),
      ],
    );
  }
}
