import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import '../../entities/holding.dart';
import '../../entities/order.dart';
import '../../repositories/i_holdings_repository.dart';
import '../../repositories/i_order_repository.dart';
import '../../repositories/i_wallet_repository.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/decimal_ext.dart';

class PlaceBuyOrderUseCase {
  PlaceBuyOrderUseCase({
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

  /// Places a buy order at [price] (LTP for market order or custom limit price).
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

    final totalValue = price * Decimal.fromInt(quantity);
    final wallet = await _walletRepo.get();

    if (totalValue > wallet.balance) {
      throw const BusinessException(AppStrings.errInsufficientBalance);
    }

    // ── Execute ───────────────────────────────────────────────────────────────
    final order = Order(
      id: _uuid.v4(),
      symbol: symbol,
      side: OrderSide.buy,
      quantity: quantity,
      executedPrice: price,
      totalValue: totalValue,
      timestamp: DateTime.now(),
    );

    // Update wallet
    final updatedWallet = wallet.copyWith(
      balance: wallet.balance - totalValue,
      totalInvested: wallet.totalInvested + totalValue,
    );

    // Update or create holding
    final existing = await _holdingsRepo.getBySymbol(symbol);
    final Holding updatedHolding;
    if (existing != null) {
      final newAvgCost = weightedAverageCost(
        oldAvgCost: existing.avgCost,
        oldQty: existing.quantity,
        newPrice: price,
        newQty: quantity,
      );
      updatedHolding = existing.copyWith(
        quantity: existing.quantity + quantity,
        avgCost: newAvgCost,
      );
    } else {
      updatedHolding = Holding(symbol: symbol, quantity: quantity, avgCost: price);
    }

    // Persist all changes
    await Future.wait([
      _walletRepo.save(updatedWallet),
      _holdingsRepo.upsert(updatedHolding),
      _orderRepo.insert(order),
    ]);

    return order;
  }
}
