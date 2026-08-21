import '../../repositories/i_watchlist_repository.dart';

class RenameWatchlistUseCase {
  const RenameWatchlistUseCase(this._repo);
  final IWatchlistRepository _repo;

  Future<void> call(String id, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) throw ArgumentError('Name cannot be empty');
    return _repo.rename(id, trimmed);
  }
}
