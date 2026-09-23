import 'package:decimal/decimal.dart';
import '../../repositories/i_holdings_repository.dart';
import '../../repositories/i_wallet_repository.dart';
import '../../repositories/i_transaction_runner.dart';
import '../../../core/errors/app_exception.dart';

/// Deletes a holding from the portfolio and refunds the invested balance to the wallet atomically.
class DeleteHoldingUseCase {
  const DeleteHoldingUseCase({
    required IHoldingsRepository holdingsRepo,
    required IWalletRepository walletRepo,
    ITransactionRunner? transactionRunner,
  })  : _holdingsRepo = holdingsRepo,
        _walletRepo = walletRepo,
        _transactionRunner = transactionRunner;

  final IHoldingsRepository _holdingsRepo;
  final IWalletRepository _walletRepo;
  final ITransactionRunner? _transactionRunner;

  Future<void> call(String symbol) async {
    final holding = await _holdingsRepo.getBySymbol(symbol);
    if (holding == null) return;

    final wallet = await _walletRepo.get();
    final updatedWallet = wallet.copyWith(
      balance: wallet.balance + holding.totalInvested,
      totalInvested: (wallet.totalInvested - holding.totalInvested)
          .clamp(Decimal.zero, wallet.totalInvested),
    );

    try {
      if (_transactionRunner != null) {
        await _transactionRunner.run(() async {
          await _holdingsRepo.delete(symbol);
          await _walletRepo.save(updatedWallet);
        });
      } else {
        await _holdingsRepo.delete(symbol);
        await _walletRepo.save(updatedWallet);
      }
    } catch (e) {
      throw StorageException('Failed to remove holding: $e');
    }
  }

  Future<void> clearAll() async {
    final holdings = await _holdingsRepo.getAll();
    final wallet = await _walletRepo.get();
    final totalInvestedToRefund = wallet.totalInvested;

    try {
      if (_transactionRunner != null) {
        await _transactionRunner.run(() async {
          for (final h in holdings) {
            await _holdingsRepo.delete(h.symbol);
          }
          await _walletRepo.save(wallet.copyWith(
            balance: wallet.balance + totalInvestedToRefund,
            totalInvested: Decimal.zero,
          ));
        });
      } else {
        for (final h in holdings) {
          await _holdingsRepo.delete(h.symbol);
        }
        await _walletRepo.save(wallet.copyWith(
          balance: wallet.balance + totalInvestedToRefund,
          totalInvested: Decimal.zero,
        ));
      }
    } catch (e) {
      throw StorageException('Failed to clear holdings: $e');
    }
  }
}
