import '../entities/holding.dart';

/// Contract for holdings persistence operations.
abstract interface class IHoldingsRepository {
  Future<List<Holding>> getAll();
  Future<Holding?> getBySymbol(String symbol);
  Future<void> upsert(Holding holding);
  Future<void> delete(String symbol);
}
