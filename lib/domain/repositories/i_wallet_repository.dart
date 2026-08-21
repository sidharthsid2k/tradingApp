import '../entities/wallet.dart';

/// Contract for wallet / balance persistence operations.
abstract interface class IWalletRepository {
  Future<Wallet> get();
  Future<void> save(Wallet wallet);
}
