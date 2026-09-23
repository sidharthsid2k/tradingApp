import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/stock_constants.dart';
import '../../core/extensions/decimal_ext.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/price_tick.dart';
import '../providers/market_viewmodel.dart';

/// Card widget to display an order (open pending or executed).
class OrderCard extends StatelessWidget {
  const OrderCard({
    required this.order,
    this.onCancel,
    super.key,
  });

  final Order order;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    final sideColor = isBuy ? AppColors.gain : AppColors.loss;
    final sideBg = isBuy ? AppColors.gainBg : AppColors.lossBg;
    final isPending = order.isPending;
    final isExecuted = order.isExecuted;
    final fmt = DateFormat('dd MMM, HH:mm:ss');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? const Color(0xFFFFD54F).withAlpha(180)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Symbol, Badges & Time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sideBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isBuy ? AppStrings.buy : AppStrings.sell,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: sideColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.orderType == OrderType.limit
                      ? AppStrings.limit
                      : AppStrings.market,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 12),

          // Symbol & Quantity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.symbol, style: AppTextStyles.ticker),
                  const SizedBox(height: 2),
                  Text(
                    StockConstants.nameFor(order.symbol),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${order.quantity} ${AppStrings.qtyLabel}',
                    style: AppTextStyles.priceLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fmt.format(order.timestamp),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),

          // Pricing & Execution Details
          if (isPending) ...[
            // Open order: show Limit Price and Live LTP
            Selector<MarketViewModel, PriceTick?>(
              selector: (_, vm) => vm.tickFor(order.symbol),
              builder: (context, tick, _) {
                final currentLtp = tick?.ltp;
                final limit = order.limitPrice;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.limitPrice,
                            style: AppTextStyles.labelSmall),
                        const SizedBox(height: 2),
                        Text(
                          limit != null ? limit.toINR() : AppStrings.flatDash,
                          style: AppTextStyles.priceLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    if (currentLtp != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.ltpLabel,
                              style: AppTextStyles.labelSmall),
                          const SizedBox(height: 2),
                          Text(
                            currentLtp.toINR(),
                            style: AppTextStyles.priceMedium,
                          ),
                        ],
                      ),
                    if (onCancel != null)
                      OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.loss,
                          side: const BorderSide(color: AppColors.loss),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          minimumSize: const Size(0, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppStrings.cancel,
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.loss,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${order.triggerDirection == TriggerDirection.gte ? 'Triggers when LTP reaches or crosses' : 'Triggers when LTP drops to'} ${order.limitPrice?.toINR() ?? ''}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFFE65100),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else if (isExecuted) ...[
            // Executed order: show executed price and total value
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.executedAt,
                        style: AppTextStyles.labelSmall),
                    const SizedBox(height: 2),
                    Text(
                      order.executedPrice?.toINR() ?? AppStrings.flatDash,
                      style: AppTextStyles.priceLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(AppStrings.orderValueLabel,
                        style: AppTextStyles.labelSmall),
                    const SizedBox(height: 2),
                    Text(
                      order.totalValue.toINR(),
                      style: AppTextStyles.priceLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            // Cancelled order
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.limitPrice}: ${order.limitPrice?.toINR() ?? AppStrings.flatDash}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textMuted),
                ),
                Text(
                  AppStrings.statusCancelled,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case OrderStatus.pending:
        bg = const Color(0xFFFFF8E1);
        fg = const Color(0xFFF57F17);
        text = AppStrings.statusPending;
        break;
      case OrderStatus.executed:
        bg = AppColors.gainBg;
        fg = AppColors.gain;
        text = AppStrings.statusExecuted;
        break;
      case OrderStatus.cancelled:
        bg = AppColors.neutralBg;
        fg = AppColors.textMuted;
        text = AppStrings.statusCancelled;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
