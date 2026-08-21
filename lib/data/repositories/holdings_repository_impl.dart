import 'package:drift/drift.dart';
import '../../domain/entities/holding.dart';
import '../../domain/repositories/i_holdings_repository.dart';
import '../datasources/local/app_database.dart';
import '../../core/extensions/decimal_ext.dart';

class HoldingsRepositoryImpl implements IHoldingsRepository {
  const HoldingsRepositoryImpl(this._db);
  final AppDatabase _db;

  @override
  Future<List<Holding>> getAll() async {
    final entries = await _db.holdingsDao.getAll();
    return entries.map(_toEntity).toList();
  }

  @override
  Future<Holding?> getBySymbol(String symbol) async {
    final entry = await _db.holdingsDao.getBySymbol(symbol);
    return entry != null ? _toEntity(entry) : null;
  }

  @override
  Future<void> upsert(Holding holding) => _db.holdingsDao.upsert(
        HoldingsCompanion(
          symbol: Value(holding.symbol),
          quantity: Value(holding.quantity),
          avgCostStr: Value(holding.avgCost.toStringAsFixed(4)),
        ),
      );

  @override
  Future<void> delete(String symbol) => _db.holdingsDao.deleteBySymbol(symbol);

  // ─── Mapping ──────────────────────────────────────────────────────────────

  static Holding _toEntity(HoldingEntry e) => Holding(
        symbol: e.symbol,
        quantity: e.quantity,
        avgCost: parseDecimalSafe(e.avgCostStr),
      );
}
