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
///
/// Each row uses [Selector] to subscribe only to its own symbol's tick.
/// Only the row whose price changed is rebuilt — no list-level rebuild.
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
          _StocksListSliver(),
        ],
      ),
    );
  }
}

class _AppBarSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background,
      expandedHeight: 90,
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
                Text(AppStrings.livePricesSubtitle,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary)),
              ],
            ),
            _LiveIndicator(),
          ],
        ),
      ),
    );
  }
}

class _LiveIndicator extends StatefulWidget {
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
    return FadeTransition(
      opacity: _ctrl,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.gain,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text('LIVE',
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.gain)),
        ],
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

class _StocksListSliver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index.isOdd) {
            return const Divider(height: 1, indent: 70);
          }
          final symbol = StockConstants.allSymbols[index ~/ 2];
          return Selector<MarketViewModel, PriceTick?>(
            // Each item independently subscribes to its own symbol
            selector: (_, vm) => vm.tickFor(symbol),
            builder: (context, tick, _) {
              return StockTickerRow(
                key: ValueKey(symbol),
                symbol: symbol,
                tick: tick,
                onTap: () => context.push(
                  '${AppRoutes.order}?symbol=$symbol&side=buy',
                ),
              );
            },
          );
        },
        childCount: StockConstants.allSymbols.length * 2 - 1,
      ),
    );
  }
}
