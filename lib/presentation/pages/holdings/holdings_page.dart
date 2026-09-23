import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/extensions/decimal_ext.dart';
import '../../providers/holdings_viewmodel.dart';
import '../../providers/market_viewmodel.dart';
import '../../widgets/holding_row.dart';
import '../../widgets/empty_state_widget.dart';

/// Feature 4: Holdings — portfolio view with live P&L, sortable, sell & delete actions.
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
              _HoldingsAppBar(vm: vm),
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
  const _HoldingsAppBar({required this.vm});
  final HoldingsViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      title: Text(AppStrings.holdingsTitle, style: AppTextStyles.headingLarge),
      titleSpacing: 20,
      actions: [
        if (!vm.isEmpty)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'clear_all') {
                _confirmClearAll(context);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined,
                        color: AppColors.loss, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Clear All Holdings',
                      style: TextStyle(color: AppColors.loss),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Clear All Holdings?'),
        content: const Text(
          'This will remove all stocks from your holdings and refund the invested balance back to your wallet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.loss,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<HoldingsViewModel>().clearAllHoldings();
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
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
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.textSecondary)),
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
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
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
          return Dismissible(
            key: Key('holding_${view.symbol}'),
            direction: DismissDirection.endToStart,
            background: Container(
              color: AppColors.loss,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete_outline_rounded,
                      color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Remove',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (_) => _confirmDeleteHolding(context, view.symbol),
            onDismissed: (_) {
              context.read<HoldingsViewModel>().deleteHolding(view.symbol);
            },
            child: HoldingRow(
              key: ValueKey(view.symbol),
              view: view,
              onTap: () => _showHoldingActions(context, view),
            ),
          );
        },
        childCount: views.length * 2 - 1,
      ),
    );
  }

  Future<bool> _confirmDeleteHolding(
      BuildContext context, String symbol) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Remove $symbol?'),
        content: Text(
          'Are you sure you want to remove $symbol from your holdings? The invested funds will be refunded to your wallet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.loss),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showHoldingActions(BuildContext context, HoldingView view) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(view.symbol, style: AppTextStyles.headingLarge),
                      Text(StockConstants.nameFor(view.symbol),
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(view.currentValue.toINR(),
                          style: AppTextStyles.priceLarge),
                      Text(
                        '${view.quantity} Shares @ ${view.avgCost.toINR()} avg',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gain,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(sheetCtx).pop();
                        context.push(
                            '${AppRoutes.order}?symbol=${view.symbol}&side=buy');
                      },
                      child: const Text('BUY MORE',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.loss,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(sheetCtx).pop();
                        context.push(
                            '${AppRoutes.order}?symbol=${view.symbol}&side=sell');
                      },
                      child: const Text('SELL',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.loss, size: 20),
                  label: const Text(
                    'Remove Holding from Portfolio',
                    style: TextStyle(
                      color: AppColors.loss,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    Navigator.of(sheetCtx).pop();
                    final shouldDelete =
                        await _confirmDeleteHolding(context, view.symbol);
                    if (shouldDelete && context.mounted) {
                      context
                          .read<HoldingsViewModel>()
                          .deleteHolding(view.symbol);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
