import '../entities/order.dart';

/// Contract for order persistence operations.
abstract interface class IOrderRepository {
  Future<List<Order>> getAll();
  Future<List<Order>> getPending();
  Future<List<Order>> getExecuted();
  Future<Order?> getById(String id);
  Future<void> insert(Order order);
  Future<void> update(Order order);
  Future<void> delete(String id);
}
