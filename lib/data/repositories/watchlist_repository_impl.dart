import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/watchlist.dart';
import '../../domain/repositories/i_watchlist_repository.dart';
import '../datasources/local/app_database.dart';

class WatchlistRepositoryImpl implements IWatchlistRepository {
  const WatchlistRepositoryImpl(this._db);
  final AppDatabase _db;

  static const _uuid = Uuid();

  @override
  Future<List<Watchlist>> getAll() async {
    final entries = await _db.watchlistDao.getAllWatchlists();
    final result = <Watchlist>[];
    for (final entry in entries) {
      final stocks = await _db.watchlistDao.getStocksForWatchlist(entry.id);
      result.add(Watchlist(
        id: entry.id,
        name: entry.name,
        symbolOrder: stocks.map((s) => s.symbol).toList(),
        sortOrder: entry.sortOrder,
      ));
    }
    return result;
  }

  @override
  Future<Watchlist> create(String name) async {
    final count = await _db.watchlistDao.countWatchlists();
    final id = _uuid.v4();
    await _db.watchlistDao.insertWatchlist(WatchlistsCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(count),
    ));
    return Watchlist(id: id, name: name, symbolOrder: const [], sortOrder: count);
  }

  @override
  Future<void> rename(String id, String newName) =>
      _db.watchlistDao.updateWatchlist(
        WatchlistsCompanion(id: Value(id), name: Value(newName)),
      );

  @override
  Future<void> delete(String id) async {
    await _db.watchlistDao.deleteAllStocksForWatchlist(id);
    await _db.watchlistDao.deleteWatchlist(id);
  }

  @override
  Future<void> addStock(String watchlistId, String symbol) async {
    final existing = await _db.watchlistDao.getStocksForWatchlist(watchlistId);
    final alreadyAdded = existing.any((s) => s.symbol == symbol);
    if (alreadyAdded) return;
    await _db.watchlistDao.insertStock(WatchlistStocksCompanion(
      watchlistId: Value(watchlistId),
      symbol: Value(symbol),
      position: Value(existing.length),
    ));
  }

  @override
  Future<void> removeStock(String watchlistId, String symbol) =>
      _db.watchlistDao.deleteStock(watchlistId, symbol);

  @override
  Future<void> reorderStock(
          String watchlistId, int oldIndex, int newIndex) =>
      _db.watchlistDao.reorderStock(watchlistId, oldIndex, newIndex);
}
