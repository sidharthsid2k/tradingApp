import 'package:drift/drift.dart';

/// Single-row wallet table.
@DataClassName('WalletEntry')
class WalletTable extends Table {
  /// Always 1 — enforces single-row semantics.
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get balanceStr => text()();
  TextColumn get totalInvestedStr => text()();

  @override
  Set<Column> get primaryKey => {id};
}
