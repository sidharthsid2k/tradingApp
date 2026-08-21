import 'package:drift/drift.dart';

/// Ordered stock entries within a watchlist.
@DataClassName('WatchlistStockEntry')
class WatchlistStocks extends Table {
  TextColumn get watchlistId => text()();
  TextColumn get symbol => text()();

  /// Zero-based position within the watchlist.
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {watchlistId, symbol};
}
