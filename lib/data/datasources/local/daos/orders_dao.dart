import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/orders_table.dart';

part 'orders_dao.g.dart';

@DriftAccessor(tables: [Orders])
class OrdersDao extends DatabaseAccessor<AppDatabase> with _$OrdersDaoMixin {
  OrdersDao(super.db);

  Future<List<OrderEntry>> getAll() =>
      (select(orders)..orderBy([(t) => OrderingTerm.desc(t.timestampMs)]))
          .get();

  Future<List<OrderEntry>> getPending() =>
      (select(orders)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.desc(t.timestampMs)]))
          .get();

  Future<List<OrderEntry>> getExecuted() =>
      (select(orders)
            ..where((t) => t.status.equals('executed'))
            ..orderBy([(t) => OrderingTerm.desc(t.timestampMs)]))
          .get();

  Future<OrderEntry?> getById(String id) =>
      (select(orders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insert(OrdersCompanion entry) => into(orders).insert(entry);

  Future<void> updateOrder(OrdersCompanion entry) =>
      (update(orders)..where((t) => t.id.equals(entry.id.value))).write(entry);

  Future<void> deleteOrder(String id) =>
      (delete(orders)..where((t) => t.id.equals(id))).go();
}
