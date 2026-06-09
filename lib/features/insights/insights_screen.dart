import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/models.dart';
import '../../shared/services/services.dart';
import '../../shared/strings.dart';
import '../../shared/theme/theme.dart';
import '../../shared/utils/currency.dart';
import '../../shared/widgets/widgets.dart';

/// Spending insights — a balance-over-time chart plus in/out/net totals, all
/// derived from the existing transaction ledger (no extra data stored).
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final txs = user == null
        ? const AsyncValue<List<BankTransaction>>.loading()
        : ref.watch(transactionsStreamProvider(user.uid));

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.insightsTitle)),
      body: SafeArea(
        child: txs.when(
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.show_chart_rounded,
                title: AppStrings.insightsEmptyTitle,
                message: AppStrings.insightsEmptyBody,
              );
            }
            return _Insights(items: items);
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

class _Insights extends StatelessWidget {
  const _Insights({required this.items});

  /// Newest-first ledger (as it comes from the stream).
  final List<BankTransaction> items;

  @override
  Widget build(BuildContext context) {
    var totalIn = 0.0;
    var totalOut = 0.0;
    for (final t in items) {
      if (t.type == TransactionType.deposit) {
        totalIn += t.amount;
      } else {
        totalOut += t.amount;
      }
    }
    final net = totalIn - totalOut;

    // Oldest-first balance points for the chart.
    final chrono = items.reversed.toList();
    final spots = [
      for (var i = 0; i < chrono.length; i++)
        FlSpot(i.toDouble(), chrono[i].balanceAfter),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.balanceOverTime, style: AppTextStyles.titleLarge),
          const SizedBox(height: AppSpacing.md),
          _ChartCard(spots: spots),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: AppStrings.totalIn,
                  value: formatXaf(totalIn),
                  color: AppColors.success,
                  icon: Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  label: AppStrings.totalOut,
                  value: formatXaf(totalOut),
                  color: AppColors.textPrimary,
                  icon: Icons.north_east_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: AppStrings.netFlow,
                  value: formatXaf(net, signed: true, withCode: true),
                  color: net >= 0 ? AppColors.success : AppColors.error,
                  icon: Icons.swap_vert_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  label: AppStrings.movements,
                  value: '${items.length}',
                  color: AppColors.accent,
                  icon: Icons.receipt_long_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.spots});
  final List<FlSpot> spots;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              color: AppColors.accent,
              barWidth: 3,
              dotData: FlDotData(
                show: spots.length <= 12,
                getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.accent,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.28),
                    AppColors.accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

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
          Icon(icon, size: 18, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.amount.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
