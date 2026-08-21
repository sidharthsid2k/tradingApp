import 'package:drift/drift.dart';

/// Immutable history of all executed orders.
@DataClassName('OrderEntry')
class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get symbol => text()();

  /// 'buy' or 'sell'
  TextColumn get side => text()();

  IntColumn get quantity => integer()();
  TextColumn get executedPriceStr => text()();
  TextColumn get totalValueStr => text()();

  /// Epoch milliseconds.
  IntColumn get timestampMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
