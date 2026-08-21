import 'package:drift/drift.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/i_wallet_repository.dart';
import '../datasources/local/app_database.dart';
import '../../core/extensions/decimal_ext.dart';

class WalletRepositoryImpl implements IWalletRepository {
  const WalletRepositoryImpl(this._db);
  final AppDatabase _db;

  @override
  Future<Wallet> get() async {
    final entry = await _db.walletDao.getOrCreate();
    return Wallet(
      balance: parseDecimalSafe(entry.balanceStr),
      totalInvested: parseDecimalSafe(entry.totalInvestedStr),
    );
  }

  @override
  Future<void> save(Wallet wallet) => _db.walletDao.save(
        WalletTableCompanion(
          id: const Value(1),
          balanceStr: Value(wallet.balance.toStringAsFixed(2)),
          totalInvestedStr: Value(wallet.totalInvested.toStringAsFixed(2)),
        ),
      );
}
