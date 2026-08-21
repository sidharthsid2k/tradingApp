import '../../repositories/i_watchlist_repository.dart';

class DeleteWatchlistUseCase {
  const DeleteWatchlistUseCase(this._repo);
  final IWatchlistRepository _repo;

  Future<void> call(String id) => _repo.delete(id);
}
