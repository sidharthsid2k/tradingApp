import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/extensions/decimal_ext.dart';
import '../../../domain/entities/order.dart';
import 'package:intl/intl.dart';

/// Order confirmation screen shown after a successful order submission.
class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({required this.order, super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    final sideColor = isBuy ? AppColors.gain : AppColors.loss;
    final sideLabel = isBuy ? AppStrings.buy : AppStrings.sell;
    final fmt = DateFormat('dd MMM yyyy, HH:mm:ss');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Success animation
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: sideColor.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: sideColor, width: 2),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: sideColor,
                  size: 52,
                ),
              )
                  .animate()
                  .scale(
                      begin: const Offset(0.4, 0.4),
                      curve: Curves.elasticOut,
                      duration: 600.ms)
                  .fadeIn(),
              const SizedBox(height: 20),
              Text(AppStrings.orderSuccess,
                      style: AppTextStyles.displayMedium)
                  .animate()
                  .slideY(begin: 0.3, duration: 350.ms, delay: 200.ms)
                  .fadeIn(),
              const SizedBox(height: 6),
              Text('${order.quantity} × ${order.symbol}',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.textSecondary))
                  .animate()
                  .fadeIn(delay: 300.ms),
              const Spacer(),
              // Order details card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _ConfirmRow(
                      label: 'Side',
                      value: sideLabel,
                      valueColor: sideColor,
                    ),
                    const Divider(height: 20),
                    _ConfirmRow(
                      label: AppStrings.executedAt,
                      value: order.executedPrice.toINR(),
                    ),
                    const Divider(height: 20),
                    _ConfirmRow(
                      label: AppStrings.orderValueLabel,
                      value: order.totalValue.toINR(),
                    ),
                    const Divider(height: 20),
                    _ConfirmRow(
                      label: AppStrings.orderTime,
                      value: fmt.format(order.timestamp),
                    ),
                    const Divider(height: 20),
                    _ConfirmRow(
                      label: AppStrings.orderId,
                      value:
                          '#${order.id.substring(0, 8).toUpperCase()}',
                      valueStyle: AppTextStyles.mono,
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 150.ms).fadeIn(),
              const SizedBox(height: 32),
              // Action buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.holdings),
                  child: Text(AppStrings.viewHoldings,
                      style: AppTextStyles.buttonLarge
                          .copyWith(color: Colors.white)),
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: Text(AppStrings.placeAnother,
                      style: AppTextStyles.buttonMedium
                          .copyWith(color: AppColors.primary)),
                ),
              ).animate().fadeIn(delay: 450.ms),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.market),
                child: Text(AppStrings.navMarket,
                    style: AppTextStyles.buttonMedium
                        .copyWith(color: AppColors.textMuted)),
              ).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueStyle,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: (valueStyle ?? AppTextStyles.bodyLarge)
                    .copyWith(color: valueColor),
                textAlign: TextAlign.end,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
