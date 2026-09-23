import '../../entities/order.dart';
import '../../repositories/i_order_repository.dart';

/// Cancels an open pending order.
class CancelOrderUseCase {
  CancelOrderUseCase(this._orderRepo);

  final IOrderRepository _orderRepo;

  Future<Order> call(Order order) async {
    final updated = order.copyWith(status: OrderStatus.cancelled);
    await _orderRepo.update(updated);
    return updated;
  }
}
