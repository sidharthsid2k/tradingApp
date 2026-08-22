import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/stock_constants.dart';
import '../../core/extensions/decimal_ext.dart';
import '../../domain/entities/price_tick.dart';

/// A row in the watchlist or live-prices list showing one stock's tick data.
class StockTickerRow extends StatelessWidget {
  const StockTickerRow({
    required this.tick,
    required this.symbol,
    this.onTap,
    this.trailing,
    super.key,
  });

  final PriceTick? tick;
  final String symbol;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _SymbolBadge(symbol: symbol),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(symbol, style: AppTextStyles.ticker),
                  const SizedBox(height: 2),
                  Text(
                    StockConstants.nameFor(symbol),
                    style: AppTextStyles.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (tick != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tick!.ltp.toINR(),
                    style: AppTextStyles.priceLarge,
                  ),
                  const SizedBox(height: 2),
                  _ChangeBadge(tick: tick!),
                ],
              ),
            ] else
              Text(AppStrings.flatDash, style: AppTextStyles.bodyMedium),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

class _SymbolBadge extends StatelessWidget {
  const _SymbolBadge({required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          symbol.length >= 2 ? symbol.substring(0, 2) : symbol,
          style: AppTextStyles.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge({required this.tick});
  final PriceTick tick;

  @override
  Widget build(BuildContext context) {
    final color = tick.isGain
        ? AppColors.gain
        : tick.isLoss
            ? AppColors.loss
            : AppColors.neutral;
    final arrow = tick.isGain
        ? AppStrings.upArrow
        : tick.isLoss
            ? AppStrings.downArrow
            : AppStrings.flatDash;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tick.isGain
            ? AppColors.gainBg
            : tick.isLoss
                ? AppColors.lossBg
                : AppColors.neutralBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(arrow, style: TextStyle(color: color, fontSize: 9)),
          const SizedBox(width: 2),
          Text(
            tick.changePercent.toPercentString().replaceAll('+', ''),
            style: AppTextStyles.priceSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
