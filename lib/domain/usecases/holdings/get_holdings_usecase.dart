import '../../entities/holding.dart';
import '../../repositories/i_holdings_repository.dart';

class GetHoldingsUseCase {
  const GetHoldingsUseCase(this._repo);
  final IHoldingsRepository _repo;

  Future<List<Holding>> call() => _repo.getAll();
}
