import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/price_tick.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../../domain/usecases/order/execute_order_usecase.dart';
import '../../domain/usecases/order/cancel_order_usecase.dart';
import '../../data/datasources/mock/mock_market_feed.dart';
import 'holdings_viewmodel.dart';

/// ViewModel managing both Open (Pending) and Executed orders.
///
/// Listens to live price ticks from [MockMarketFeed]. Whenever a tick satisfies
/// the limit price condition of a pending order, it automatically executes the
/// order, updates the portfolio holdings, and moves the order to Executed.
class OrdersViewModel extends ChangeNotifier {
  OrdersViewModel({
    required IOrderRepository orderRepo,
    required ExecuteOrderUseCase executeOrderUseCase,
    required CancelOrderUseCase cancelOrderUseCase,
    required MockMarketFeed feed,
    HoldingsViewModel? holdingsViewModel,
  })  : _orderRepo = orderRepo,
        _executeOrder = executeOrderUseCase,
        _cancelOrder = cancelOrderUseCase,
        _feed = feed,
        _holdingsViewModel = holdingsViewModel {
    loadOrders();
    _sub = _feed.ticks.listen(_onTick);
  }

  final IOrderRepository _orderRepo;
  final ExecuteOrderUseCase _executeOrder;
  final CancelOrderUseCase _cancelOrder;
  final MockMarketFeed _feed;
  HoldingsViewModel? _holdingsViewModel;

  late final StreamSubscription<PriceTick> _sub;
  bool _isLoading = false;
  List<Order> _orders = [];

  bool get isLoading => _isLoading;
  List<Order> get allOrders => _orders;

  List<Order> get openOrders =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();

  List<Order> get executedOrders =>
      _orders.where((o) => o.status == OrderStatus.executed).toList();

  int get pendingCount => openOrders.length;

  void attachHoldingsViewModel(HoldingsViewModel vm) {
    _holdingsViewModel = vm;
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await _orderRepo.getAll();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancels an open pending order.
  Future<void> cancel(Order order) async {
    await _cancelOrder(order);
    await loadOrders();
  }

  /// Called on every market tick to match against open pending limit orders.
  Future<void> _onTick(PriceTick tick) async {
    final pendingForSymbol = _orders
        .where((o) => o.isPending && o.symbol == tick.symbol)
        .toList();

    if (pendingForSymbol.isEmpty) return;

    bool anyExecuted = false;

    for (final order in pendingForSymbol) {
      final target = order.limitPrice;
      if (target == null) continue;

      bool isTriggered = false;
      if (order.triggerDirection == TriggerDirection.gte) {
        isTriggered = tick.ltp >= target;
      } else if (order.triggerDirection == TriggerDirection.lte) {
        isTriggered = tick.ltp <= target;
      } else {
        // Fallback: exact match or crossed
        isTriggered = tick.ltp == target;
      }

      if (isTriggered) {
        await _executeOrder(order: order, executionPrice: tick.ltp);
        anyExecuted = true;
      }
    }

    if (anyExecuted) {
      await loadOrders();
      _holdingsViewModel?.loadAll();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
