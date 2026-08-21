import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/orders_table.dart';

part 'orders_dao.g.dart';

@DriftAccessor(tables: [Orders])
class OrdersDao extends DatabaseAccessor<AppDatabase> with _$OrdersDaoMixin {
  OrdersDao(super.db);

  Future<List<OrderEntry>> getAll() =>
      (select(orders)
            ..orderBy([(t) => OrderingTerm.desc(t.timestampMs)]))
          .get();

  Future<void> insert(OrdersCompanion entry) =>
      into(orders).insert(entry);
}
