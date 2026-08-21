import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/holdings_table.dart';

part 'holdings_dao.g.dart';

@DriftAccessor(tables: [Holdings])
class HoldingsDao extends DatabaseAccessor<AppDatabase>
    with _$HoldingsDaoMixin {
  HoldingsDao(super.db);

  Future<List<HoldingEntry>> getAll() => select(holdings).get();

  Future<HoldingEntry?> getBySymbol(String symbol) =>
      (select(holdings)..where((t) => t.symbol.equals(symbol)))
          .getSingleOrNull();

  Future<void> upsert(HoldingsCompanion entry) =>
      into(holdings).insertOnConflictUpdate(entry);

  Future<void> deleteBySymbol(String symbol) =>
      (delete(holdings)..where((t) => t.symbol.equals(symbol))).go();
}
