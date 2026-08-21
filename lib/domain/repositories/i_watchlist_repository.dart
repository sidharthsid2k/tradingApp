import '../entities/watchlist.dart';

/// Contract for watchlist persistence operations.
abstract interface class IWatchlistRepository {
  Future<List<Watchlist>> getAll();
  Future<Watchlist> create(String name);
  Future<void> rename(String id, String newName);
  Future<void> delete(String id);
  Future<void> addStock(String watchlistId, String symbol);
  Future<void> removeStock(String watchlistId, String symbol);
  Future<void> reorderStock(String watchlistId, int oldIndex, int newIndex);
}
