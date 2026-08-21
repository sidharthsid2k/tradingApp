import '../../repositories/i_watchlist_repository.dart';

class RemoveStockFromWatchlistUseCase {
  const RemoveStockFromWatchlistUseCase(this._repo);
  final IWatchlistRepository _repo;

  Future<void> call(String watchlistId, String symbol) =>
      _repo.removeStock(watchlistId, symbol);
}
