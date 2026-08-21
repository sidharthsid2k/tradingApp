import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/extensions/decimal_ext.dart';
import '../../providers/holdings_viewmodel.dart';
import '../../providers/market_viewmodel.dart';
import '../../widgets/holding_row.dart';
import '../../widgets/empty_state_widget.dart';

/// Feature 4: Holdings — portfolio view with live P&L, sortable.
class HoldingsPage extends StatelessWidget {
  const HoldingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Wire market ticks into holdings VM whenever ticks change
    return Selector<MarketViewModel, int>(
      selector: (_, marketVm) => marketVm.allTicks.length,
      shouldRebuild: (prev, next) => true,
      builder: (context, count, child) {
        final marketVm = context.read<MarketViewModel>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context
              .read<HoldingsViewModel>()
              .refreshWithTicks({for (final t in marketVm.allTicks) t.symbol: t});
        });
        return const _HoldingsContent();
      },
    );
  }
}

class _HoldingsContent extends StatelessWidget {
  const _HoldingsContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<HoldingsViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              const _HoldingsAppBar(),
              if (vm.isEmpty)
                SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.account_balance_wallet_outlined,
                    title: AppStrings.emptyHoldingsTitle,
                    subtitle: AppStrings.emptyHoldingsSubtitle,
                    action: () => context.go(AppRoutes.market),
                    actionLabel: AppStrings.navMarket,
                  ),
                )
              else ...[
                _HoldingsSummarySliver(vm: vm),
                _SortChipsSliver(vm: vm),
                _HoldingsListSliver(vm: vm),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HoldingsAppBar extends StatelessWidget {
  const _HoldingsAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      title: Text(AppStrings.holdingsTitle, style: AppTextStyles.headingLarge),
      titleSpacing: 20,
    );
  }
}

class _HoldingsSummarySliver extends StatelessWidget {
  const _HoldingsSummarySliver({required this.vm});
  final HoldingsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final isGain = vm.totalPnl >= Decimal.zero;
    final pnlColor = isGain ? AppColors.gain : AppColors.loss;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _SummaryCol(
                label: AppStrings.totalInvested,
                value: vm.totalInvested.toINR(),
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.border),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _SummaryCol(
                  label: AppStrings.currentValueLabel,
                  value: vm.totalCurrentValue.toINR(),
                ),
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.border),
            Expanded(
              child: _SummaryCol(
                label: AppStrings.totalPnlLabel,
                value: vm.totalPnl.toSignedINR(),
                sub: vm.totalPnlPercent.toPercentString(),
                valueColor: pnlColor,
                crossAxisAlignment: CrossAxisAlignment.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCol extends StatelessWidget {
  const _SummaryCol({
    required this.label,
    required this.value,
    this.sub,
    this.valueColor,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTextStyles.priceLarge.copyWith(
              fontSize: 16,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
        if (sub != null) ...[
          const SizedBox(height: 3),
          Text(
            sub!,
            style: AppTextStyles.labelMedium.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _SortChipsSliver extends StatelessWidget {
  const _SortChipsSliver({required this.vm});
  final HoldingsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final orders = [
      HoldingsSortOrder.pnlDesc,
      HoldingsSortOrder.symbol,
      HoldingsSortOrder.value,
    ];
    final labels = [
      AppStrings.sortByPnl,
      AppStrings.sortBySymbol,
      AppStrings.sortByValue,
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Row(
          children: [
            Text(AppStrings.sortBy,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
            const SizedBox(width: 8),
            ...List.generate(orders.length, (i) {
              final isSelected = vm.sortOrder == orders[i];
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(labels[i]),
                  selected: isSelected,
                  onSelected: (_) => vm.setSortOrder(orders[i]),
                  selectedColor: AppColors.primaryBg,
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    color:
                        isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HoldingsListSliver extends StatelessWidget {
  const _HoldingsListSliver({required this.vm});
  final HoldingsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final views = vm.holdingViews;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index.isOdd) return const Divider(height: 1, indent: 70);
          final view = views[index ~/ 2];
          return HoldingRow(
            key: ValueKey(view.symbol),
            view: view,
            onTap: () => context.push(
              '${AppRoutes.order}?symbol=${view.symbol}&side=buy',
            ),
          );
        },
        childCount: views.length * 2 - 1,
      ),
    );
  }
}
