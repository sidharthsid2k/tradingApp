import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/price_tick.dart';
import '../../providers/market_viewmodel.dart';
import '../../widgets/stock_ticker_row.dart';

/// Feature 2: Live Prices — shows all 10 stocks with real-time prices.
class LivePricesPage extends StatelessWidget {
  const LivePricesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _AppBarSliver(),
          _MarketSummarySliver(),
          _StockListSliver(),
        ],
      ),
    );
  }
}

class _AppBarSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final marketVm = context.watch<MarketViewModel>();
    final isOpen = marketVm.isMarketOpen;
    final isSimulating = marketVm.isSimulationMode;

    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      expandedHeight: 90,
      actions: [
        // Simulation Mode Quick Switch
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextButton.icon(
            onPressed: () => marketVm.toggleSimulationMode(),
            icon: Icon(
              isSimulating
                  ? Icons.play_circle_filled_rounded
                  : Icons.pause_circle_outline_rounded,
              size: 16,
              color: isSimulating ? AppColors.primary : AppColors.textMuted,
            ),
            label: Text(
              isSimulating ? 'Sim: ON' : 'Sim: OFF',
              style: AppTextStyles.labelSmall.copyWith(
                color: isSimulating ? AppColors.primary : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: isSimulating
                  ? AppColors.primaryBg
                  : AppColors.surfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.livePricesTitle,
                    style: AppTextStyles.headingLarge),
                Text(
                  isOpen
                      ? 'NSE · Real-time'
                      : isSimulating
                          ? 'NSE · Simulated Ticks'
                          : 'NSE · Closed (Opens 9:15 AM)',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isOpen
                        ? AppColors.primary
                        : isSimulating
                            ? AppColors.secondary
                            : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            _LiveIndicator(
              isOpen: isOpen || isSimulating,
              isSimulated: isSimulating && !isOpen,
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveIndicator extends StatefulWidget {
  const _LiveIndicator({required this.isOpen, this.isSimulated = false});
  final bool isOpen;
  final bool isSimulated;

  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.neutral,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'CLOSED',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: widget.isSimulated ? AppColors.secondaryBg : AppColors.gainBg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: widget.isSimulated ? AppColors.secondary : AppColors.gain,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              widget.isSimulated ? 'SIMULATING' : 'LIVE',
              style: AppTextStyles.labelSmall.copyWith(
                color: widget.isSimulated ? AppColors.secondary : AppColors.gain,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketSummarySliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Selector<MarketViewModel, List<PriceTick>>(
        selector: (_, vm) => vm.allTicks,
        shouldRebuild: (prev, next) => true,
        builder: (context, ticks, _) {
          final gainers = ticks.where((t) => t.isGain).length;
          final losers = ticks.where((t) => t.isLoss).length;
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.cardBg, AppColors.surfaceVariant],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryChip(
                    label: 'Gainers',
                    value: '$gainers',
                    color: AppColors.gain),
                Container(width: 1, height: 28, color: AppColors.border),
                _SummaryChip(
                    label: 'Losers',
                    value: '$losers',
                    color: AppColors.loss),
                Container(width: 1, height: 28, color: AppColors.border),
                _SummaryChip(
                    label: 'Tracked',
                    value: '${StockConstants.allSymbols.length}',
                    color: AppColors.secondary),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style:
                AppTextStyles.headingLarge.copyWith(color: color, fontSize: 22)),
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _StockListSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final symbol = StockConstants.allSymbols[index];
          return Selector<MarketViewModel, PriceTick?>(
            selector: (_, vm) => vm.tickFor(symbol),
            builder: (context, tick, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StockTickerRow(
                    key: ValueKey(symbol),
                    symbol: symbol,
                    tick: tick,
                    onTap: () => context.push(
                      '${AppRoutes.order}?symbol=$symbol&side=buy',
                    ),
                  ),
                  const Divider(height: 1, indent: 70),
                ],
              );
            },
          );
        },
        childCount: StockConstants.allSymbols.length,
      ),
    );
  }
}
