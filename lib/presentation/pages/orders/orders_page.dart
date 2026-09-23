import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/entities/order.dart';
import '../../providers/orders_viewmodel.dart';
import '../../widgets/order_card.dart';
import '../../widgets/empty_state_widget.dart';

/// Screen displaying user orders divided into "Open" (pending) and "Executed".
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OrdersContent();
  }
}

class _OrdersContent extends StatelessWidget {
  const _OrdersContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<OrdersViewModel>();
    final openOrders = vm.openOrders;
    final executedOrders = vm.executedOrders;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(AppStrings.ordersTitle, style: AppTextStyles.headingLarge),
          titleSpacing: 20,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle:
                AppTextStyles.buttonMedium.copyWith(fontWeight: FontWeight.w700),
            unselectedLabelStyle: AppTextStyles.buttonMedium,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppStrings.tabOpenOrders),
                    if (openOrders.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF57F17),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${openOrders.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppStrings.tabExecutedOrders),
                    if (executedOrders.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${executedOrders.length}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ─── Tab 1: Open Orders ─────────────────────────────────────────
            openOrders.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.hourglass_top_rounded,
                    title: AppStrings.emptyOpenOrdersTitle,
                    subtitle: AppStrings.emptyOpenOrdersSubtitle,
                    action: () => context.go(AppRoutes.market),
                    actionLabel: AppStrings.navMarket,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: openOrders.length,
                    itemBuilder: (context, index) {
                      final order = openOrders[index];
                      return OrderCard(
                        order: order,
                        onCancel: () => _confirmCancel(context, order),
                      );
                    },
                  ),

            // ─── Tab 2: Executed Orders ─────────────────────────────────────
            executedOrders.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.check_circle_outline_rounded,
                    title: AppStrings.emptyExecutedOrdersTitle,
                    subtitle: AppStrings.emptyExecutedOrdersSubtitle,
                    action: () => context.go(AppRoutes.market),
                    actionLabel: AppStrings.navMarket,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: executedOrders.length,
                    itemBuilder: (context, index) {
                      final order = executedOrders[index];
                      return OrderCard(order: order);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text(AppStrings.cancelOrder),
        content: Text(
          'Cancel ${order.side == OrderSide.buy ? 'BUY' : 'SELL'} order for ${order.quantity} × ${order.symbol}?',
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
              context.read<OrdersViewModel>().cancel(order);
            },
            child: const Text(
              AppStrings.confirm,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
