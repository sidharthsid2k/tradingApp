import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import '../../entities/holding.dart';
import '../../entities/order.dart';
import '../../repositories/i_holdings_repository.dart';
import '../../repositories/i_order_repository.dart';
import '../../repositories/i_wallet_repository.dart';
import '../../repositories/i_transaction_runner.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/decimal_ext.dart';

class PlaceBuyOrderUseCase {
  PlaceBuyOrderUseCase({
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

  /// Places a buy order.
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

    final totalValue = price * Decimal.fromInt(quantity);
    final wallet = await _walletRepo.get();

    if (totalValue > wallet.balance) {
      throw const BusinessException(AppStrings.errInsufficientBalance);
    }

    final ltp = (currentLtp != null && currentLtp > Decimal.zero)
        ? currentLtp
        : price;

    final isLimitPending = orderType == OrderType.limit && price != ltp;

    if (isLimitPending) {
      final triggerDirection =
          price > ltp ? TriggerDirection.gte : TriggerDirection.lte;

      final pendingOrder = Order(
        id: _uuid.v4(),
        symbol: symbol,
        side: OrderSide.buy,
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
        throw StorageException('Failed to place pending order: $e');
      }

      return pendingOrder;
    }

    // ── Immediate Execution ───────────────────────────────────────────────────
    final execPrice = orderType == OrderType.market ? ltp : price;
    final execTotalValue = execPrice * Decimal.fromInt(quantity);

    final order = Order(
      id: _uuid.v4(),
      symbol: symbol,
      side: OrderSide.buy,
      quantity: quantity,
      orderType: orderType,
      status: OrderStatus.executed,
      limitPrice: orderType == OrderType.limit ? price : null,
      executedPrice: execPrice,
      totalValue: execTotalValue,
      timestamp: DateTime.now(),
    );

    // Update wallet
    final updatedWallet = wallet.copyWith(
      balance: wallet.balance - execTotalValue,
      totalInvested: wallet.totalInvested + execTotalValue,
    );

    // Update or create holding
    final existing = await _holdingsRepo.getBySymbol(symbol);
    final Holding updatedHolding;
    if (existing != null) {
      final newAvgCost = weightedAverageCost(
        oldAvgCost: existing.avgCost,
        oldQty: existing.quantity,
        newPrice: execPrice,
        newQty: quantity,
      );
      updatedHolding = existing.copyWith(
        quantity: existing.quantity + quantity,
        avgCost: newAvgCost,
      );
    } else {
      updatedHolding =
          Holding(symbol: symbol, quantity: quantity, avgCost: execPrice);
    }

    // ── Atomic Transaction Persistence ─────────────────────────────────────────
    try {
      if (_transactionRunner != null) {
        await _transactionRunner.run(() async {
          await _walletRepo.save(updatedWallet);
          await _holdingsRepo.upsert(updatedHolding);
          await _orderRepo.insert(order);
        });
      } else {
        await _walletRepo.save(updatedWallet);
        await _holdingsRepo.upsert(updatedHolding);
        await _orderRepo.insert(order);
      }
    } catch (e) {
      throw StorageException('Failed to execute trade: $e');
    }

    return order;
  }
}
