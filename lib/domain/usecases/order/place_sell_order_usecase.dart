import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import '../../entities/order.dart';
import '../../repositories/i_holdings_repository.dart';
import '../../repositories/i_order_repository.dart';
import '../../repositories/i_wallet_repository.dart';
import '../../repositories/i_transaction_runner.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/constants/app_strings.dart';

class PlaceSellOrderUseCase {
  PlaceSellOrderUseCase({
    required IWalletRepository walletRepo,
    required IHoldingsRepository holdingsRepo,
    required IOrderRepository orderRepo,
    ITransactionRunner? transactionRunner,
  })  : _walletRepo = walletRepo,
        _holdingsRepo = holdingsRepo,
        _orderRepo = orderRepo,
        _transactionRunner = transactionRunner;

  final IWalletRepository _walletRepo;
  final IHoldingsRepository _holdingsRepo;
  final IOrderRepository _orderRepo;
  final ITransactionRunner? _transactionRunner;

  static const _uuid = Uuid();

  /// Places a sell order.
  /// If [orderType] is Limit and [price] does not equal [currentLtp],
  /// the order is placed with status `OrderStatus.pending` and queued in Orders.
  /// Otherwise, it executes atomically inside a database transaction.
  Future<Order> call({
    required String symbol,
    required int quantity,
    required Decimal price,
    OrderType orderType = OrderType.market,
    Decimal? currentLtp,
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

    final ltp = (currentLtp != null && currentLtp > Decimal.zero)
        ? currentLtp
        : price;

    final isLimitPending = orderType == OrderType.limit && price != ltp;
    final totalValue = price * Decimal.fromInt(quantity);

    if (isLimitPending) {
      final triggerDirection =
          price > ltp ? TriggerDirection.gte : TriggerDirection.lte;

      final pendingOrder = Order(
        id: _uuid.v4(),
        symbol: symbol,
        side: OrderSide.sell,
        quantity: quantity,
        orderType: OrderType.limit,
        status: OrderStatus.pending,
        limitPrice: price,
        executedPrice: null,
        totalValue: totalValue,
        timestamp: DateTime.now(),
        triggerDirection: triggerDirection,
      );

      try {
        await _orderRepo.insert(pendingOrder);
      } catch (e) {
        throw StorageException('Failed to place pending sell order: $e');
      }

      return pendingOrder;
    }

    // ── Immediate Execution ───────────────────────────────────────────────────
    final execPrice = orderType == OrderType.market ? ltp : price;
    final execTotalValue = execPrice * Decimal.fromInt(quantity);

    final order = Order(
      id: _uuid.v4(),
      symbol: symbol,
      side: OrderSide.sell,
      quantity: quantity,
      orderType: orderType,
      status: OrderStatus.executed,
      limitPrice: orderType == OrderType.limit ? price : null,
      executedPrice: execPrice,
      totalValue: execTotalValue,
      timestamp: DateTime.now(),
    );

    final wallet = await _walletRepo.get();

    // Credit proceeds to wallet; reduce totalInvested by avg cost of sold shares
    final costOfSoldShares = holding.avgCost * Decimal.fromInt(quantity);
    final updatedWallet = wallet.copyWith(
      balance: wallet.balance + execTotalValue,
      totalInvested: (wallet.totalInvested - costOfSoldShares)
          .clamp(Decimal.zero, wallet.totalInvested),
    );

    final remainingQty = holding.quantity - quantity;

    // ── Atomic Transaction Persistence ─────────────────────────────────────────
    try {
      if (_transactionRunner != null) {
        await _transactionRunner.run(() async {
          await _walletRepo.save(updatedWallet);
          if (remainingQty <= 0) {
            await _holdingsRepo.delete(symbol);
          } else {
            await _holdingsRepo
                .upsert(holding.copyWith(quantity: remainingQty));
          }
          await _orderRepo.insert(order);
        });
      } else {
        await _walletRepo.save(updatedWallet);
        if (remainingQty <= 0) {
          await _holdingsRepo.delete(symbol);
        } else {
          await _holdingsRepo.upsert(holding.copyWith(quantity: remainingQty));
        }
        await _orderRepo.insert(order);
      }
    } catch (e) {
      throw StorageException('Failed to execute sell trade: $e');
    }

    return order;
  }
}
