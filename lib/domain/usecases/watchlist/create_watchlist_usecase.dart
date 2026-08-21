import '../../entities/watchlist.dart';
import '../../repositories/i_watchlist_repository.dart';

class CreateWatchlistUseCase {
  const CreateWatchlistUseCase(this._repo);
  final IWatchlistRepository _repo;

  /// Creates a new watchlist with the given [name].
  /// Throws [ValidationException] if [name] is blank.
  Future<Watchlist> call(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Watchlist name cannot be empty');
    }
    return _repo.create(trimmed);
  }
}
