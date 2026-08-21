import '../entities/order.dart';

/// Contract for order history persistence operations.
abstract interface class IOrderRepository {
  Future<List<Order>> getAll();
  Future<void> insert(Order order);
}
