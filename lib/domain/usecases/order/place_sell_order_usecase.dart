import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import '../../entities/order.dart';
import '../../repositories/i_holdings_repository.dart';
import '../../repositories/i_order_repository.dart';
import '../../repositories/i_wallet_repository.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/constants/app_strings.dart';

class PlaceSellOrderUseCase {
  PlaceSellOrderUseCase({
    required IWalletRepository walletRepo,
    required IHoldingsRepository holdingsRepo,
    required IOrderRepository orderRepo,
  })  : _walletRepo = walletRepo,
        _holdingsRepo = holdingsRepo,
        _orderRepo = orderRepo;

  final IWalletRepository _walletRepo;
  final IHoldingsRepository _holdingsRepo;
  final IOrderRepository _orderRepo;

  static const _uuid = Uuid();

  Future<Order> call({
    required String symbol,
    required int quantity,
    required Decimal price,
  }) async {
    // ── Validation ────────────────────────────────────────────────────────────
    if (quantity <= 0) {
      throw const ValidationException(AppStrings.errQtyPositive);
    }
    if (price <= Decimal.zero) {
      throw const ValidationException(AppStrings.errInvalidPrice);
    }

    final holding = await _holdingsRepo.getBySymbol(symbol);
    if (holding == null) {
      throw const BusinessException(AppStrings.errNoHoldings);
    }
    if (quantity > holding.quantity) {
      throw const BusinessException(AppStrings.errInsufficientQty);
    }

    // ── Execute ───────────────────────────────────────────────────────────────
    final totalValue = price * Decimal.fromInt(quantity);

    final order = Order(
      id: _uuid.v4(),
      symbol: symbol,
      side: OrderSide.sell,
      quantity: quantity,
      executedPrice: price,
      totalValue: totalValue,
      timestamp: DateTime.now(),
    );

    final wallet = await _walletRepo.get();

    // Credit proceeds to wallet; reduce totalInvested by avg cost of sold shares
    final costOfSoldShares = holding.avgCost * Decimal.fromInt(quantity);
    final updatedWallet = wallet.copyWith(
      balance: wallet.balance + totalValue,
      totalInvested: (wallet.totalInvested - costOfSoldShares)
          .clamp(Decimal.zero, wallet.totalInvested),
    );

    // Persist
    final remainingQty = holding.quantity - quantity;
    await Future.wait([
      _walletRepo.save(updatedWallet),
      if (remainingQty <= 0)
        _holdingsRepo.delete(symbol)
      else
        _holdingsRepo.upsert(holding.copyWith(quantity: remainingQty)),
      _orderRepo.insert(order),
    ]);

    return order;
  }
}
