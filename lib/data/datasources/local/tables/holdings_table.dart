import 'package:drift/drift.dart';

/// Current portfolio positions.
@DataClassName('HoldingEntry')
class Holdings extends Table {
  TextColumn get symbol => text()();
  IntColumn get quantity => integer()();

  /// Avg cost stored as a String to preserve Decimal precision losslessly.
  TextColumn get avgCostStr => text()();

  @override
  Set<Column> get primaryKey => {symbol};
}
