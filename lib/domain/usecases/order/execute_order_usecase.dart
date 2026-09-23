import 'package:decimal/decimal.dart';
import '../../entities/holding.dart';
import '../../entities/order.dart';
import '../../repositories/i_holdings_repository.dart';
import '../../repositories/i_order_repository.dart';
import '../../repositories/i_wallet_repository.dart';
import '../../repositories/i_transaction_runner.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/decimal_ext.dart';

/// Executes an open/pending order atomically when its market trigger price is reached.
class ExecuteOrderUseCase {
  ExecuteOrderUseCase({
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

  Future<Order> call({
    required Order order,
    required Decimal executionPrice,
  }) async {
    final quantity = order.quantity;
    final totalValue = executionPrice * Decimal.fromInt(quantity);
    final wallet = await _walletRepo.get();

    if (order.side == OrderSide.buy) {
      if (totalValue > wallet.balance) {
        // Insufficient balance at execution time; cancel order
        final cancelled = order.copyWith(status: OrderStatus.cancelled);
        await _orderRepo.update(cancelled);
        return cancelled;
      }

      // 1. Update wallet
      final updatedWallet = wallet.copyWith(
        balance: wallet.balance - totalValue,
        totalInvested: wallet.totalInvested + totalValue,
      );

      // 2. Update holdings
      final existing = await _holdingsRepo.getBySymbol(order.symbol);
      final Holding updatedHolding;
      if (existing != null) {
        final newAvgCost = weightedAverageCost(
          oldAvgCost: existing.avgCost,
          oldQty: existing.quantity,
          newPrice: executionPrice,
          newQty: quantity,
        );
        updatedHolding = existing.copyWith(
          quantity: existing.quantity + quantity,
          avgCost: newAvgCost,
        );
      } else {
        updatedHolding = Holding(
          symbol: order.symbol,
          quantity: quantity,
          avgCost: executionPrice,
        );
      }

      // 3. Update order to executed
      final executedOrder = order.copyWith(
        status: OrderStatus.executed,
        executedPrice: executionPrice,
        totalValue: totalValue,
        timestamp: DateTime.now(),
      );

      // ── Atomic Transaction Persistence ─────────────────────────────────────
      try {
        if (_transactionRunner != null) {
          await _transactionRunner.run(() async {
            await _walletRepo.save(updatedWallet);
            await _holdingsRepo.upsert(updatedHolding);
            await _orderRepo.update(executedOrder);
          });
        } else {
          await _walletRepo.save(updatedWallet);
          await _holdingsRepo.upsert(updatedHolding);
          await _orderRepo.update(executedOrder);
        }
      } catch (e) {
        throw StorageException('Failed to execute pending buy order: $e');
      }

      return executedOrder;
    } else {
      // SELL
      final holding = await _holdingsRepo.getBySymbol(order.symbol);
      if (holding == null || holding.quantity < quantity) {
        final cancelled = order.copyWith(status: OrderStatus.cancelled);
        await _orderRepo.update(cancelled);
        return cancelled;
      }

      final costOfSoldShares = holding.avgCost * Decimal.fromInt(quantity);
      final updatedWallet = wallet.copyWith(
        balance: wallet.balance + totalValue,
        totalInvested: (wallet.totalInvested - costOfSoldShares)
            .clamp(Decimal.zero, wallet.totalInvested),
      );

      final remainingQty = holding.quantity - quantity;
      final executedOrder = order.copyWith(
        status: OrderStatus.executed,
        executedPrice: executionPrice,
        totalValue: totalValue,
        timestamp: DateTime.now(),
      );

      // ── Atomic Transaction Persistence ─────────────────────────────────────
      try {
        if (_transactionRunner != null) {
          await _transactionRunner.run(() async {
            await _walletRepo.save(updatedWallet);
            if (remainingQty <= 0) {
              await _holdingsRepo.delete(order.symbol);
            } else {
              await _holdingsRepo.upsert(
                  holding.copyWith(quantity: remainingQty));
            }
            await _orderRepo.update(executedOrder);
          });
        } else {
          await _walletRepo.save(updatedWallet);
          if (remainingQty <= 0) {
            await _holdingsRepo.delete(order.symbol);
          } else {
            await _holdingsRepo
                .upsert(holding.copyWith(quantity: remainingQty));
          }
          await _orderRepo.update(executedOrder);
        }
      } catch (e) {
        throw StorageException('Failed to execute pending sell order: $e');
      }

      return executedOrder;
    }
  }
}
