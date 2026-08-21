import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Displays P&L value + percent with appropriate colour and sign.
class PnlBadge extends StatelessWidget {
  const PnlBadge({
    required this.pnlText,
    required this.pnlPercentText,
    required this.isPositive,
    this.large = false,
    super.key,
  });

  final String pnlText;
  final String pnlPercentText;
  final bool isPositive;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.gain : AppColors.loss;
    final bgColor = isPositive ? AppColors.gainBg : AppColors.lossBg;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 12 : 8, vertical: large ? 6 : 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(large ? 10 : 6),
        border: Border.all(
            color: isPositive ? AppColors.gain : AppColors.loss,
            width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            large ? CrossAxisAlignment.center : CrossAxisAlignment.end,
        children: [
          Text(
            pnlText,
            style: (large ? AppTextStyles.priceLarge : AppTextStyles.priceMedium)
                .copyWith(color: color),
          ),
          Text(
            pnlPercentText,
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
