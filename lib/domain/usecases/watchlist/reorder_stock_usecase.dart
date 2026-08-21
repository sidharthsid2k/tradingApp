import '../../repositories/i_watchlist_repository.dart';

class ReorderStockUseCase {
  const ReorderStockUseCase(this._repo);
  final IWatchlistRepository _repo;

  Future<void> call(String watchlistId, int oldIndex, int newIndex) =>
      _repo.reorderStock(watchlistId, oldIndex, newIndex);
}
