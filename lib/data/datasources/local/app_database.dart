import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/watchlists_table.dart';
import 'tables/watchlist_stocks_table.dart';
import 'tables/holdings_table.dart';
import 'tables/orders_table.dart';
import 'tables/wallet_table.dart';
import 'daos/watchlist_dao.dart';
import 'daos/holdings_dao.dart';
import 'daos/orders_dao.dart';
import 'daos/wallet_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Watchlists, WatchlistStocks, Holdings, Orders, WalletTable],
  daos: [WatchlistDao, HoldingsDao, OrdersDao, WalletDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tradingapp.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
