import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/extensions/decimal_ext.dart';
import '../providers/holdings_viewmodel.dart';

/// A single row in the holdings list with live P&L.
class HoldingRow extends StatelessWidget {
  const HoldingRow({
    required this.view,
    required this.onTap,
    super.key,
  });

  final HoldingView view;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pnlColor = view.pnl.isPositive
        ? AppColors.gain
        : view.pnl.isNegative
            ? AppColors.loss
            : AppColors.neutral;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                // Symbol badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      view.symbol.length >= 2
                          ? view.symbol.substring(0, 2)
                          : view.symbol,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Symbol + qty column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(view.symbol, style: AppTextStyles.ticker),
                      const SizedBox(height: 2),
                      Text(
                        '${view.quantity} ${AppStrings.qtyLabel} × ${view.avgCost.toINR()} avg',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                // Current value + P&L
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      view.currentValue.toINR(),
                      style: AppTextStyles.priceLarge,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          view.pnl.toSignedINR(),
                          style: AppTextStyles.priceSmall.copyWith(color: pnlColor),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: view.pnl.isPositive
                                ? AppColors.gainBg
                                : view.pnl.isNegative
                                    ? AppColors.lossBg
                                    : AppColors.neutralBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            view.pnlPercent.toPercentString(),
                            style: AppTextStyles.labelSmall
                                .copyWith(color: pnlColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // LTP row
            Row(
              children: [
                const SizedBox(width: 52),
                Expanded(
                  child: Row(
                    children: [
                      _MetricChip(
                          label: AppStrings.ltpLabel,
                          value: view.ltp.toINR()),
                      const SizedBox(width: 8),
                      _MetricChip(
                          label: AppStrings.avgCost,
                          value: view.avgCost.toINR()),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const SizedBox(width: 4),
          Text(value,
              style: AppTextStyles.priceSmall
                  .copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
