import '../../repositories/i_watchlist_repository.dart';

class AddStockToWatchlistUseCase {
  const AddStockToWatchlistUseCase(this._repo);
  final IWatchlistRepository _repo;

  Future<void> call(String watchlistId, String symbol) =>
      _repo.addStock(watchlistId, symbol);
}
