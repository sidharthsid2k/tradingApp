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
  Future<void> insert(Order order) => _db.ordersDao.insert(
        OrdersCompanion(
          id: Value(order.id),
          symbol: Value(order.symbol),
          side: Value(order.side == OrderSide.buy ? 'buy' : 'sell'),
          quantity: Value(order.quantity),
          executedPriceStr: Value(order.executedPrice.toStringAsFixed(2)),
          totalValueStr: Value(order.totalValue.toStringAsFixed(2)),
          timestampMs: Value(order.timestamp.millisecondsSinceEpoch),
        ),
      );

  static Order _toEntity(OrderEntry e) => Order(
        id: e.id,
        symbol: e.symbol,
        side: e.side == 'buy' ? OrderSide.buy : OrderSide.sell,
        quantity: e.quantity,
        executedPrice: parseDecimalSafe(e.executedPriceStr),
        totalValue: parseDecimalSafe(e.totalValueStr),
        timestamp: DateTime.fromMillisecondsSinceEpoch(e.timestampMs),
      );
}
