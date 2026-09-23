import 'package:drift/drift.dart';

/// Database table for orders (both pending limit orders and completed/cancelled trades).
@DataClassName('OrderEntry')
class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get symbol => text()();

  /// 'buy' or 'sell'
  TextColumn get side => text()();

  /// 'market' or 'limit'
  TextColumn get orderType => text().withDefault(const Constant('market'))();

  /// 'pending', 'executed', or 'cancelled'
  TextColumn get status => text().withDefault(const Constant('executed'))();

  IntColumn get quantity => integer()();

  /// Target limit price as string (null for market orders).
  TextColumn get limitPriceStr => text().nullable()();

  /// Actual execution price as string (null while pending).
  TextColumn get executedPriceStr => text().nullable()();

  TextColumn get totalValueStr => text()();

  /// 'gte' or 'lte'
  TextColumn get triggerDirection => text().nullable()();

  /// Epoch milliseconds.
  IntColumn get timestampMs => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
