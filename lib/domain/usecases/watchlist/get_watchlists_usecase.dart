import '../../entities/watchlist.dart';
import '../../repositories/i_watchlist_repository.dart';

class GetWatchlistsUseCase {
  const GetWatchlistsUseCase(this._repo);
  final IWatchlistRepository _repo;

  Future<List<Watchlist>> call() => _repo.getAll();
}
