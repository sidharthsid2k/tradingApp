import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/stock_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/extensions/decimal_ext.dart';
import '../../../domain/entities/price_tick.dart';
import '../../../domain/usecases/order/place_buy_order_usecase.dart';
import '../../../domain/usecases/order/place_sell_order_usecase.dart';
import '../../../domain/repositories/i_wallet_repository.dart';
import '../../../domain/repositories/i_holdings_repository.dart';
import '../../../domain/repositories/i_order_repository.dart';
import '../../providers/market_viewmodel.dart';
import '../../providers/order_viewmodel.dart';
import '../../providers/holdings_viewmodel.dart';

/// Feature 3: Buy/Sell Ticket — full-screen order form with live LTP.
class OrderTicketPage extends StatelessWidget {
  const OrderTicketPage({
    required this.symbol,
    required this.initialSide,
    super.key,
  });

  final String symbol;
  final String initialSide;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OrderViewModel(
        symbol: symbol,
        initialSide:
            initialSide == 'sell' ? OrderSideUi.sell : OrderSideUi.buy,
        placeBuyOrder: PlaceBuyOrderUseCase(
          walletRepo: context.read<IWalletRepository>(),
          holdingsRepo: context.read<IHoldingsRepository>(),
          orderRepo: context.read<IOrderRepository>(),
        ),
        placeSellOrder: PlaceSellOrderUseCase(
          walletRepo: context.read<IWalletRepository>(),
          holdingsRepo: context.read<IHoldingsRepository>(),
          orderRepo: context.read<IOrderRepository>(),
        ),
        walletRepo: context.read<IWalletRepository>(),
        holdingsRepo: context.read<IHoldingsRepository>(),
      ),
      child: _OrderTicketContent(symbol: symbol),
    );
  }
}

class _OrderTicketContent extends StatelessWidget {
  const _OrderTicketContent({required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context) {
    // Wire market tick into OrderViewModel on every tick
    return Selector<MarketViewModel, PriceTick?>(
      selector: (_, vm) => vm.tickFor(symbol),
      builder: (context, tick, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.read<OrderViewModel>().updateTick(tick);
          }
        });
        return const _OrderTicketScaffold();
      },
    );
  }
}

class _OrderTicketScaffold extends StatefulWidget {
  const _OrderTicketScaffold();

  @override
  State<_OrderTicketScaffold> createState() => _OrderTicketScaffoldState();
}

class _OrderTicketScaffoldState extends State<_OrderTicketScaffold> {
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrderViewModel>();

    // Sync limit price text field if view model updated it automatically
    if (_priceCtrl.text.isEmpty && vm.priceText.isNotEmpty && vm.orderType == OrderTypeUi.limit) {
      _priceCtrl.text = vm.priceText;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.orderTicketTitle,
            style: AppTextStyles.headingLarge),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StockHeader(vm: vm),
            if (vm.holdingView != null) ...[
              const SizedBox(height: 16),
              _ExistingHoldingCard(vm: vm),
            ],
            const SizedBox(height: 20),
            _SideSwitcher(vm: vm),
            const SizedBox(height: 20),
            _LiveLtpCard(vm: vm),
            const SizedBox(height: 24),
            _QtyInput(vm: vm, ctrl: _qtyCtrl),
            const SizedBox(height: 16),
            _PriceInput(vm: vm, ctrl: _priceCtrl),
            if (vm.validationError != null &&
                (vm.quantityText.isNotEmpty || vm.priceText.isNotEmpty)) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Text(
                  vm.validationError!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFFE65100),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _OrderSummaryCard(vm: vm),
            const SizedBox(height: 28),
            _SubmitButton(vm: vm),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _ExistingHoldingCard extends StatelessWidget {
  const _ExistingHoldingCard({required this.vm});
  final OrderViewModel vm;

  @override
  Widget build(BuildContext context) {
    final view = vm.holdingView;
    if (view == null) return const SizedBox.shrink();

    final pnlColor = view.pnl.isPositive
        ? AppColors.gain
        : view.pnl.isNegative
            ? AppColors.loss
            : AppColors.neutral;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => context.go(AppRoutes.holdings),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${view.quantity} ${view.quantity == 1 ? 'Share' : 'Shares'}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppStrings.avgPrice} ${view.avgCost.toINR()}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      view.currentValue.toINR(),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${view.pnl.toSignedINR()} (${view.pnlPercent.toPercentString()})',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: pnlColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StockHeader extends StatelessWidget {
  const _StockHeader({required this.vm});
  final OrderViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              vm.symbol.length >= 2 ? vm.symbol.substring(0, 2) : vm.symbol,
              style: AppTextStyles.headingMedium
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vm.symbol, style: AppTextStyles.headingLarge),
            Text(StockConstants.nameFor(vm.symbol),
                style: AppTextStyles.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _SideSwitcher extends StatelessWidget {
  const _SideSwitcher({required this.vm});
  final OrderViewModel vm;

  @override
  Widget build(BuildContext context) {
    final isBuy = vm.side == OrderSideUi.buy;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _SideBtn(
            label: AppStrings.buy,
            isActive: isBuy,
            activeColor: AppColors.gain,
            onTap: () => context.read<OrderViewModel>().setSide(OrderSideUi.buy),
          ),
          _SideBtn(
            label: AppStrings.sell,
            isActive: !isBuy,
            activeColor: AppColors.loss,
            onTap: () =>
                context.read<OrderViewModel>().setSide(OrderSideUi.sell),
          ),
        ],
      ),
    );
  }
}

class _SideBtn extends StatelessWidget {
  const _SideBtn({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.buttonMedium.copyWith(
                  color: isActive ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveLtpCard extends StatelessWidget {
  const _LiveLtpCard({required this.vm});
  final OrderViewModel vm;

  @override
  Widget build(BuildContext context) {
    final isBuy = vm.side == OrderSideUi.buy;
    final accentColor = isBuy ? AppColors.gain : AppColors.loss;
    final tick = vm.latestTick;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.ltpLabel,
                  style: AppTextStyles.labelMedium),
              if (tick != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tick.isGain ? AppColors.gainBg : AppColors.lossBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tick.changePercent.toPercentString(),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: tick.isGain ? AppColors.gain : AppColors.loss,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    vm.ltp.toINR(),
                    style: AppTextStyles.priceDisplay.copyWith(color: accentColor),
                  ),
                ),
              ),
              if (tick != null) ...[
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tick.change.toSignedINR(),
                      style: AppTextStyles.priceSmall.copyWith(
                        color: tick.isGain ? AppColors.gain : AppColors.loss,
                      ),
                    ),
                    Text('from open', style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyInput extends StatelessWidget {
  const _QtyInput({required this.vm, required this.ctrl});
  final OrderViewModel vm;
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppStrings.qtyLabel} NSE',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.unfold_more_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 170,
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            textAlign: TextAlign.end,
            style: AppTextStyles.priceLarge.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: AppStrings.orderQtyHint,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onChanged: (v) => context.read<OrderViewModel>().setQuantity(v),
          ),
        ),
      ],
    );
  }
}

class _PriceInput extends StatelessWidget {
  const _PriceInput({required this.vm, required this.ctrl});
  final OrderViewModel vm;
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    final isLimit = vm.orderType == OrderTypeUi.limit;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            context.read<OrderViewModel>().toggleOrderType();
            final updatedVm = context.read<OrderViewModel>();
            if (updatedVm.orderType == OrderTypeUi.limit) {
              ctrl.text = updatedVm.priceText;
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLimit ? AppStrings.priceLimitLabel : AppStrings.priceMarketLabel,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.unfold_more_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 170,
          child: isLimit
              ? TextField(
                  controller: ctrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  textAlign: TextAlign.end,
                  style: AppTextStyles.priceLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  onChanged: (v) => context.read<OrderViewModel>().setPrice(v),
                )
              : InkWell(
                  onTap: () {
                    context.read<OrderViewModel>().setOrderType(OrderTypeUi.limit);
                    ctrl.text = context.read<OrderViewModel>().priceText;
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 46,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withAlpha(120),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      AppStrings.atMarket,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.vm});
  final OrderViewModel vm;

  @override
  Widget build(BuildContext context) {
    final isBuy = vm.side == OrderSideUi.buy;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _Row(
            label: isBuy ? AppStrings.availableBalance : AppStrings.qtyHeld,
            value: isBuy
                ? (vm.wallet?.balance.toINR() ?? AppStrings.flatDash)
                : '${vm.holding?.quantity ?? 0} ${AppStrings.qtyLabel}',
          ),
          const Divider(height: 16),
          _Row(
            label: AppStrings.orderValueLabel,
            value: vm.projectedValue > Decimal.zero
                ? vm.projectedValue.toINR()
                : AppStrings.flatDash,
            valueStyle: AppTextStyles.priceLarge
                .copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.valueStyle});
  final String label;
  final String value;
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
                style: valueStyle ?? AppTextStyles.bodyLarge,
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

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.vm});
  final OrderViewModel vm;

  @override
  Widget build(BuildContext context) {
    final isBuy = vm.side == OrderSideUi.buy;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isBuy ? AppColors.gain : AppColors.loss,
          disabledBackgroundColor: AppColors.border,
        ),
        onPressed: vm.canSubmit ? () => _submit(context) : null,
        child: vm.isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child:
                    CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                '${isBuy ? AppStrings.buy : AppStrings.sell} ${vm.symbol}',
                style: AppTextStyles.buttonLarge
                    .copyWith(color: Colors.white),
              ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final vm = context.read<OrderViewModel>();
    final order = await vm.submit();
    if (order != null && context.mounted) {
      // Reload holdings so P&L is fresh
      context.read<HoldingsViewModel>().loadAll();
      context.pushReplacement(AppRoutes.orderConfirmation, extra: order);
    }
  }
}
