import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/watchlists_table.dart';
import '../tables/watchlist_stocks_table.dart';

part 'watchlist_dao.g.dart';

@DriftAccessor(tables: [Watchlists, WatchlistStocks])
class WatchlistDao extends DatabaseAccessor<AppDatabase>
    with _$WatchlistDaoMixin {
  WatchlistDao(super.db);

  // ─── Watchlist CRUD ─────────────────────────────────────────────────────────

  Future<List<WatchlistEntry>> getAllWatchlists() =>
      (select(watchlists)..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .get();

  Future<void> insertWatchlist(WatchlistsCompanion entry) =>
      into(watchlists).insert(entry);

  Future<void> updateWatchlist(WatchlistsCompanion entry) =>
      (update(watchlists)..where((t) => t.id.equals(entry.id.value)))
          .write(entry);

  Future<void> deleteWatchlist(String id) =>
      (delete(watchlists)..where((t) => t.id.equals(id))).go();

  Future<int> countWatchlists() async {
    final count = watchlists.id.count();
    final query = selectOnly(watchlists)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ─── Watchlist Stocks ────────────────────────────────────────────────────────

  Future<List<WatchlistStockEntry>> getStocksForWatchlist(
          String watchlistId) =>
      (select(watchlistStocks)
            ..where((t) => t.watchlistId.equals(watchlistId))
            ..orderBy([(t) => OrderingTerm(expression: t.position)]))
          .get();

  Future<void> insertStock(WatchlistStocksCompanion entry) =>
      into(watchlistStocks).insertOnConflictUpdate(entry);

  Future<void> deleteStock(String watchlistId, String symbol) =>
      (delete(watchlistStocks)
            ..where((t) =>
                t.watchlistId.equals(watchlistId) & t.symbol.equals(symbol)))
          .go();

  Future<void> deleteAllStocksForWatchlist(String watchlistId) =>
      (delete(watchlistStocks)
            ..where((t) => t.watchlistId.equals(watchlistId)))
          .go();

  /// Reorders [symbol] from [oldIndex] to [newIndex] within [watchlistId].
  /// All positions are rewritten in a single transaction.
  Future<void> reorderStock(
      String watchlistId, int oldIndex, int newIndex) async {
    await transaction(() async {
      final rows = await getStocksForWatchlist(watchlistId);
      final symbols = rows.map((r) => r.symbol).toList();

      if (oldIndex < 0 ||
          oldIndex >= symbols.length ||
          newIndex < 0 ||
          newIndex >= symbols.length) {
        return;
      }

      final symbol = symbols.removeAt(oldIndex);
      symbols.insert(newIndex, symbol);

      // Delete and reinsert to update all positions atomically
      await deleteAllStocksForWatchlist(watchlistId);
      for (var i = 0; i < symbols.length; i++) {
        await into(watchlistStocks).insert(WatchlistStocksCompanion(
          watchlistId: Value(watchlistId),
          symbol: Value(symbols[i]),
          position: Value(i),
        ));
      }
    });
  }
}
