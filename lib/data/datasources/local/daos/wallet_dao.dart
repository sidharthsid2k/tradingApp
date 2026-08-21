import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/wallet_table.dart';
import '../../../../core/constants/stock_constants.dart';

part 'wallet_dao.g.dart';

@DriftAccessor(tables: [WalletTable])
class WalletDao extends DatabaseAccessor<AppDatabase> with _$WalletDaoMixin {
  WalletDao(super.db);

  Future<WalletEntry?> get() =>
      (select(walletTable)..where((t) => t.id.equals(1))).getSingleOrNull();

  Future<void> save(WalletTableCompanion entry) =>
      into(walletTable).insertOnConflictUpdate(entry);

  /// Initialises wallet with default balance if not present.
  Future<WalletEntry> getOrCreate() async {
    final existing = await get();
    if (existing != null) return existing;

    final initial = WalletTableCompanion(
      id: const Value(1),
      balanceStr: Value(StockConstants.initialWalletBalance.toString()),
      totalInvestedStr: const Value('0'),
    );
    await save(initial);
    return (await get())!;
  }
}
