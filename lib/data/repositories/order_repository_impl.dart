import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../datasources/local/app_database.dart';
import '../../core/extensions/decimal_ext.dart';

class OrderRepositoryImpl implements IOrderRepository {
  const OrderRepositoryImpl(this._db);
  final AppDatabase _db;

  @override
  Future<List<Order>> getAll() async {
    final entries = await _db.ordersDao.getAll();
    return entries.map(_toEntity).toList();
  }

  @override
  Future<List<Order>> getPending() async {
    final entries = await _db.ordersDao.getPending();
    return entries.map(_toEntity).toList();
  }

  @override
  Future<List<Order>> getExecuted() async {
    final entries = await _db.ordersDao.getExecuted();
    return entries.map(_toEntity).toList();
  }

  @override
  Future<Order?> getById(String id) async {
    final entry = await _db.ordersDao.getById(id);
    return entry != null ? _toEntity(entry) : null;
  }

  @override
  Future<void> insert(Order order) => _db.ordersDao.insert(_toCompanion(order));

  @override
  Future<void> update(Order order) =>
      _db.ordersDao.updateOrder(_toCompanion(order));

  @override
  Future<void> delete(String id) => _db.ordersDao.deleteOrder(id);

  static OrdersCompanion _toCompanion(Order order) => OrdersCompanion(
        id: Value(order.id),
        symbol: Value(order.symbol),
        side: Value(order.side == OrderSide.buy ? 'buy' : 'sell'),
        orderType:
            Value(order.orderType == OrderType.limit ? 'limit' : 'market'),
        status: Value(_statusToString(order.status)),
        quantity: Value(order.quantity),
        limitPriceStr: Value(order.limitPrice?.toStringAsFixed(2)),
        executedPriceStr: Value(order.executedPrice?.toStringAsFixed(2)),
        totalValueStr: Value(order.totalValue.toStringAsFixed(2)),
        triggerDirection: Value(order.triggerDirection == null
            ? null
            : order.triggerDirection == TriggerDirection.gte
                ? 'gte'
                : 'lte'),
        timestampMs: Value(order.timestamp.millisecondsSinceEpoch),
      );

  static Order _toEntity(OrderEntry e) {
    final orderType =
        e.orderType == 'limit' ? OrderType.limit : OrderType.market;
    final status = _stringToStatus(e.status);
    final triggerDirection = e.triggerDirection == 'gte'
        ? TriggerDirection.gte
        : e.triggerDirection == 'lte'
            ? TriggerDirection.lte
            : null;

    final Decimal? execPrice = e.executedPriceStr != null
        ? parseDecimalSafe(e.executedPriceStr!)
        : null;
    final Decimal? limitPrice =
        e.limitPriceStr != null ? parseDecimalSafe(e.limitPriceStr!) : null;

    return Order(
      id: e.id,
      symbol: e.symbol,
      side: e.side == 'buy' ? OrderSide.buy : OrderSide.sell,
      quantity: e.quantity,
      orderType: orderType,
      status: status,
      limitPrice: limitPrice,
      executedPrice: execPrice,
      totalValue: parseDecimalSafe(e.totalValueStr),
      timestamp: DateTime.fromMillisecondsSinceEpoch(e.timestampMs),
      triggerDirection: triggerDirection,
    );
  }

  static String _statusToString(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.executed:
        return 'executed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus _stringToStatus(String s) {
    switch (s) {
      case 'pending':
        return OrderStatus.pending;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'executed':
      default:
        return OrderStatus.executed;
    }
  }
}
