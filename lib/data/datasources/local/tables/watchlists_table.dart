import 'package:drift/drift.dart';

/// Watchlist tab entries.
@DataClassName('WatchlistEntry')
class Watchlists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Sort order for tab display.
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
