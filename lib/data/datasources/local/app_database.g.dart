// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WatchlistsTable extends Watchlists
    with TableInfo<$WatchlistsTable, WatchlistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchlistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watchlists';
  @override
  VerificationContext validateIntegrity(Insertable<WatchlistEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchlistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchlistEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $WatchlistsTable createAlias(String alias) {
    return $WatchlistsTable(attachedDatabase, alias);
  }
}

class WatchlistEntry extends DataClass implements Insertable<WatchlistEntry> {
  final String id;
  final String name;

  /// Sort order for tab display.
  final int sortOrder;
  const WatchlistEntry(
      {required this.id, required this.name, required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WatchlistsCompanion toCompanion(bool nullToAbsent) {
    return WatchlistsCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory WatchlistEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchlistEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WatchlistEntry copyWith({String? id, String? name, int? sortOrder}) =>
      WatchlistEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  WatchlistEntry copyWithCompanion(WatchlistsCompanion data) {
    return WatchlistEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchlistEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class WatchlistsCompanion extends UpdateCompanion<WatchlistEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const WatchlistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchlistsCompanion.insert({
    required String id,
    required String name,
    required int sortOrder,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        sortOrder = Value(sortOrder);
  static Insertable<WatchlistEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchlistsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return WatchlistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchlistStocksTable extends WatchlistStocks
    with TableInfo<$WatchlistStocksTable, WatchlistStockEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchlistStocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _watchlistIdMeta =
      const VerificationMeta('watchlistId');
  @override
  late final GeneratedColumn<String> watchlistId = GeneratedColumn<String>(
      'watchlist_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [watchlistId, symbol, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watchlist_stocks';
  @override
  VerificationContext validateIntegrity(
      Insertable<WatchlistStockEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('watchlist_id')) {
      context.handle(
          _watchlistIdMeta,
          watchlistId.isAcceptableOrUnknown(
              data['watchlist_id']!, _watchlistIdMeta));
    } else if (isInserting) {
      context.missing(_watchlistIdMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {watchlistId, symbol};
  @override
  WatchlistStockEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchlistStockEntry(
      watchlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}watchlist_id'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $WatchlistStocksTable createAlias(String alias) {
    return $WatchlistStocksTable(attachedDatabase, alias);
  }
}

class WatchlistStockEntry extends DataClass
    implements Insertable<WatchlistStockEntry> {
  final String watchlistId;
  final String symbol;

  /// Zero-based position within the watchlist.
  final int position;
  const WatchlistStockEntry(
      {required this.watchlistId,
      required this.symbol,
      required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['watchlist_id'] = Variable<String>(watchlistId);
    map['symbol'] = Variable<String>(symbol);
    map['position'] = Variable<int>(position);
    return map;
  }

  WatchlistStocksCompanion toCompanion(bool nullToAbsent) {
    return WatchlistStocksCompanion(
      watchlistId: Value(watchlistId),
      symbol: Value(symbol),
      position: Value(position),
    );
  }

  factory WatchlistStockEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchlistStockEntry(
      watchlistId: serializer.fromJson<String>(json['watchlistId']),
      symbol: serializer.fromJson<String>(json['symbol']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'watchlistId': serializer.toJson<String>(watchlistId),
      'symbol': serializer.toJson<String>(symbol),
      'position': serializer.toJson<int>(position),
    };
  }

  WatchlistStockEntry copyWith(
          {String? watchlistId, String? symbol, int? position}) =>
      WatchlistStockEntry(
        watchlistId: watchlistId ?? this.watchlistId,
        symbol: symbol ?? this.symbol,
        position: position ?? this.position,
      );
  WatchlistStockEntry copyWithCompanion(WatchlistStocksCompanion data) {
    return WatchlistStockEntry(
      watchlistId:
          data.watchlistId.present ? data.watchlistId.value : this.watchlistId,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistStockEntry(')
          ..write('watchlistId: $watchlistId, ')
          ..write('symbol: $symbol, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(watchlistId, symbol, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchlistStockEntry &&
          other.watchlistId == this.watchlistId &&
          other.symbol == this.symbol &&
          other.position == this.position);
}

class WatchlistStocksCompanion extends UpdateCompanion<WatchlistStockEntry> {
  final Value<String> watchlistId;
  final Value<String> symbol;
  final Value<int> position;
  final Value<int> rowid;
  const WatchlistStocksCompanion({
    this.watchlistId = const Value.absent(),
    this.symbol = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchlistStocksCompanion.insert({
    required String watchlistId,
    required String symbol,
    required int position,
    this.rowid = const Value.absent(),
  })  : watchlistId = Value(watchlistId),
        symbol = Value(symbol),
        position = Value(position);
  static Insertable<WatchlistStockEntry> custom({
    Expression<String>? watchlistId,
    Expression<String>? symbol,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (watchlistId != null) 'watchlist_id': watchlistId,
      if (symbol != null) 'symbol': symbol,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchlistStocksCompanion copyWith(
      {Value<String>? watchlistId,
      Value<String>? symbol,
      Value<int>? position,
      Value<int>? rowid}) {
    return WatchlistStocksCompanion(
      watchlistId: watchlistId ?? this.watchlistId,
      symbol: symbol ?? this.symbol,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (watchlistId.present) {
      map['watchlist_id'] = Variable<String>(watchlistId.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistStocksCompanion(')
          ..write('watchlistId: $watchlistId, ')
          ..write('symbol: $symbol, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HoldingsTable extends Holdings
    with TableInfo<$HoldingsTable, HoldingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HoldingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _avgCostStrMeta =
      const VerificationMeta('avgCostStr');
  @override
  late final GeneratedColumn<String> avgCostStr = GeneratedColumn<String>(
      'avg_cost_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [symbol, quantity, avgCostStr];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holdings';
  @override
  VerificationContext validateIntegrity(Insertable<HoldingEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('avg_cost_str')) {
      context.handle(
          _avgCostStrMeta,
          avgCostStr.isAcceptableOrUnknown(
              data['avg_cost_str']!, _avgCostStrMeta));
    } else if (isInserting) {
      context.missing(_avgCostStrMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol};
  @override
  HoldingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HoldingEntry(
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      avgCostStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avg_cost_str'])!,
    );
  }

  @override
  $HoldingsTable createAlias(String alias) {
    return $HoldingsTable(attachedDatabase, alias);
  }
}

class HoldingEntry extends DataClass implements Insertable<HoldingEntry> {
  final String symbol;
  final int quantity;

  /// Avg cost stored as a String to preserve Decimal precision losslessly.
  final String avgCostStr;
  const HoldingEntry(
      {required this.symbol, required this.quantity, required this.avgCostStr});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['quantity'] = Variable<int>(quantity);
    map['avg_cost_str'] = Variable<String>(avgCostStr);
    return map;
  }

  HoldingsCompanion toCompanion(bool nullToAbsent) {
    return HoldingsCompanion(
      symbol: Value(symbol),
      quantity: Value(quantity),
      avgCostStr: Value(avgCostStr),
    );
  }

  factory HoldingEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HoldingEntry(
      symbol: serializer.fromJson<String>(json['symbol']),
      quantity: serializer.fromJson<int>(json['quantity']),
      avgCostStr: serializer.fromJson<String>(json['avgCostStr']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'quantity': serializer.toJson<int>(quantity),
      'avgCostStr': serializer.toJson<String>(avgCostStr),
    };
  }

  HoldingEntry copyWith({String? symbol, int? quantity, String? avgCostStr}) =>
      HoldingEntry(
        symbol: symbol ?? this.symbol,
        quantity: quantity ?? this.quantity,
        avgCostStr: avgCostStr ?? this.avgCostStr,
      );
  HoldingEntry copyWithCompanion(HoldingsCompanion data) {
    return HoldingEntry(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      avgCostStr:
          data.avgCostStr.present ? data.avgCostStr.value : this.avgCostStr,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HoldingEntry(')
          ..write('symbol: $symbol, ')
          ..write('quantity: $quantity, ')
          ..write('avgCostStr: $avgCostStr')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(symbol, quantity, avgCostStr);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HoldingEntry &&
          other.symbol == this.symbol &&
          other.quantity == this.quantity &&
          other.avgCostStr == this.avgCostStr);
}

class HoldingsCompanion extends UpdateCompanion<HoldingEntry> {
  final Value<String> symbol;
  final Value<int> quantity;
  final Value<String> avgCostStr;
  final Value<int> rowid;
  const HoldingsCompanion({
    this.symbol = const Value.absent(),
    this.quantity = const Value.absent(),
    this.avgCostStr = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HoldingsCompanion.insert({
    required String symbol,
    required int quantity,
    required String avgCostStr,
    this.rowid = const Value.absent(),
  })  : symbol = Value(symbol),
        quantity = Value(quantity),
        avgCostStr = Value(avgCostStr);
  static Insertable<HoldingEntry> custom({
    Expression<String>? symbol,
    Expression<int>? quantity,
    Expression<String>? avgCostStr,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (quantity != null) 'quantity': quantity,
      if (avgCostStr != null) 'avg_cost_str': avgCostStr,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HoldingsCompanion copyWith(
      {Value<String>? symbol,
      Value<int>? quantity,
      Value<String>? avgCostStr,
      Value<int>? rowid}) {
    return HoldingsCompanion(
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      avgCostStr: avgCostStr ?? this.avgCostStr,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (avgCostStr.present) {
      map['avg_cost_str'] = Variable<String>(avgCostStr.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HoldingsCompanion(')
          ..write('symbol: $symbol, ')
          ..write('quantity: $quantity, ')
          ..write('avgCostStr: $avgCostStr, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, OrderEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
      'side', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _executedPriceStrMeta =
      const VerificationMeta('executedPriceStr');
  @override
  late final GeneratedColumn<String> executedPriceStr = GeneratedColumn<String>(
      'executed_price_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalValueStrMeta =
      const VerificationMeta('totalValueStr');
  @override
  late final GeneratedColumn<String> totalValueStr = GeneratedColumn<String>(
      'total_value_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMsMeta =
      const VerificationMeta('timestampMs');
  @override
  late final GeneratedColumn<int> timestampMs = GeneratedColumn<int>(
      'timestamp_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        symbol,
        side,
        quantity,
        executedPriceStr,
        totalValueStr,
        timestampMs
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(Insertable<OrderEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
          _sideMeta, side.isAcceptableOrUnknown(data['side']!, _sideMeta));
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('executed_price_str')) {
      context.handle(
          _executedPriceStrMeta,
          executedPriceStr.isAcceptableOrUnknown(
              data['executed_price_str']!, _executedPriceStrMeta));
    } else if (isInserting) {
      context.missing(_executedPriceStrMeta);
    }
    if (data.containsKey('total_value_str')) {
      context.handle(
          _totalValueStrMeta,
          totalValueStr.isAcceptableOrUnknown(
              data['total_value_str']!, _totalValueStrMeta));
    } else if (isInserting) {
      context.missing(_totalValueStrMeta);
    }
    if (data.containsKey('timestamp_ms')) {
      context.handle(
          _timestampMsMeta,
          timestampMs.isAcceptableOrUnknown(
              data['timestamp_ms']!, _timestampMsMeta));
    } else if (isInserting) {
      context.missing(_timestampMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      side: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}side'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      executedPriceStr: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}executed_price_str'])!,
      totalValueStr: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}total_value_str'])!,
      timestampMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp_ms'])!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class OrderEntry extends DataClass implements Insertable<OrderEntry> {
  final String id;
  final String symbol;

  /// 'buy' or 'sell'
  final String side;
  final int quantity;
  final String executedPriceStr;
  final String totalValueStr;

  /// Epoch milliseconds.
  final int timestampMs;
  const OrderEntry(
      {required this.id,
      required this.symbol,
      required this.side,
      required this.quantity,
      required this.executedPriceStr,
      required this.totalValueStr,
      required this.timestampMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['symbol'] = Variable<String>(symbol);
    map['side'] = Variable<String>(side);
    map['quantity'] = Variable<int>(quantity);
    map['executed_price_str'] = Variable<String>(executedPriceStr);
    map['total_value_str'] = Variable<String>(totalValueStr);
    map['timestamp_ms'] = Variable<int>(timestampMs);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      symbol: Value(symbol),
      side: Value(side),
      quantity: Value(quantity),
      executedPriceStr: Value(executedPriceStr),
      totalValueStr: Value(totalValueStr),
      timestampMs: Value(timestampMs),
    );
  }

  factory OrderEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderEntry(
      id: serializer.fromJson<String>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      side: serializer.fromJson<String>(json['side']),
      quantity: serializer.fromJson<int>(json['quantity']),
      executedPriceStr: serializer.fromJson<String>(json['executedPriceStr']),
      totalValueStr: serializer.fromJson<String>(json['totalValueStr']),
      timestampMs: serializer.fromJson<int>(json['timestampMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'symbol': serializer.toJson<String>(symbol),
      'side': serializer.toJson<String>(side),
      'quantity': serializer.toJson<int>(quantity),
      'executedPriceStr': serializer.toJson<String>(executedPriceStr),
      'totalValueStr': serializer.toJson<String>(totalValueStr),
      'timestampMs': serializer.toJson<int>(timestampMs),
    };
  }

  OrderEntry copyWith(
          {String? id,
          String? symbol,
          String? side,
          int? quantity,
          String? executedPriceStr,
          String? totalValueStr,
          int? timestampMs}) =>
      OrderEntry(
        id: id ?? this.id,
        symbol: symbol ?? this.symbol,
        side: side ?? this.side,
        quantity: quantity ?? this.quantity,
        executedPriceStr: executedPriceStr ?? this.executedPriceStr,
        totalValueStr: totalValueStr ?? this.totalValueStr,
        timestampMs: timestampMs ?? this.timestampMs,
      );
  OrderEntry copyWithCompanion(OrdersCompanion data) {
    return OrderEntry(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      side: data.side.present ? data.side.value : this.side,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      executedPriceStr: data.executedPriceStr.present
          ? data.executedPriceStr.value
          : this.executedPriceStr,
      totalValueStr: data.totalValueStr.present
          ? data.totalValueStr.value
          : this.totalValueStr,
      timestampMs:
          data.timestampMs.present ? data.timestampMs.value : this.timestampMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderEntry(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('side: $side, ')
          ..write('quantity: $quantity, ')
          ..write('executedPriceStr: $executedPriceStr, ')
          ..write('totalValueStr: $totalValueStr, ')
          ..write('timestampMs: $timestampMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, symbol, side, quantity, executedPriceStr, totalValueStr, timestampMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderEntry &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.side == this.side &&
          other.quantity == this.quantity &&
          other.executedPriceStr == this.executedPriceStr &&
          other.totalValueStr == this.totalValueStr &&
          other.timestampMs == this.timestampMs);
}

class OrdersCompanion extends UpdateCompanion<OrderEntry> {
  final Value<String> id;
  final Value<String> symbol;
  final Value<String> side;
  final Value<int> quantity;
  final Value<String> executedPriceStr;
  final Value<String> totalValueStr;
  final Value<int> timestampMs;
  final Value<int> rowid;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.side = const Value.absent(),
    this.quantity = const Value.absent(),
    this.executedPriceStr = const Value.absent(),
    this.totalValueStr = const Value.absent(),
    this.timestampMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String id,
    required String symbol,
    required String side,
    required int quantity,
    required String executedPriceStr,
    required String totalValueStr,
    required int timestampMs,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        symbol = Value(symbol),
        side = Value(side),
        quantity = Value(quantity),
        executedPriceStr = Value(executedPriceStr),
        totalValueStr = Value(totalValueStr),
        timestampMs = Value(timestampMs);
  static Insertable<OrderEntry> custom({
    Expression<String>? id,
    Expression<String>? symbol,
    Expression<String>? side,
    Expression<int>? quantity,
    Expression<String>? executedPriceStr,
    Expression<String>? totalValueStr,
    Expression<int>? timestampMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (side != null) 'side': side,
      if (quantity != null) 'quantity': quantity,
      if (executedPriceStr != null) 'executed_price_str': executedPriceStr,
      if (totalValueStr != null) 'total_value_str': totalValueStr,
      if (timestampMs != null) 'timestamp_ms': timestampMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith(
      {Value<String>? id,
      Value<String>? symbol,
      Value<String>? side,
      Value<int>? quantity,
      Value<String>? executedPriceStr,
      Value<String>? totalValueStr,
      Value<int>? timestampMs,
      Value<int>? rowid}) {
    return OrdersCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      side: side ?? this.side,
      quantity: quantity ?? this.quantity,
      executedPriceStr: executedPriceStr ?? this.executedPriceStr,
      totalValueStr: totalValueStr ?? this.totalValueStr,
      timestampMs: timestampMs ?? this.timestampMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (executedPriceStr.present) {
      map['executed_price_str'] = Variable<String>(executedPriceStr.value);
    }
    if (totalValueStr.present) {
      map['total_value_str'] = Variable<String>(totalValueStr.value);
    }
    if (timestampMs.present) {
      map['timestamp_ms'] = Variable<int>(timestampMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('side: $side, ')
          ..write('quantity: $quantity, ')
          ..write('executedPriceStr: $executedPriceStr, ')
          ..write('totalValueStr: $totalValueStr, ')
          ..write('timestampMs: $timestampMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletTableTable extends WalletTable
    with TableInfo<$WalletTableTable, WalletEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _balanceStrMeta =
      const VerificationMeta('balanceStr');
  @override
  late final GeneratedColumn<String> balanceStr = GeneratedColumn<String>(
      'balance_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalInvestedStrMeta =
      const VerificationMeta('totalInvestedStr');
  @override
  late final GeneratedColumn<String> totalInvestedStr = GeneratedColumn<String>(
      'total_invested_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, balanceStr, totalInvestedStr];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_table';
  @override
  VerificationContext validateIntegrity(Insertable<WalletEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('balance_str')) {
      context.handle(
          _balanceStrMeta,
          balanceStr.isAcceptableOrUnknown(
              data['balance_str']!, _balanceStrMeta));
    } else if (isInserting) {
      context.missing(_balanceStrMeta);
    }
    if (data.containsKey('total_invested_str')) {
      context.handle(
          _totalInvestedStrMeta,
          totalInvestedStr.isAcceptableOrUnknown(
              data['total_invested_str']!, _totalInvestedStrMeta));
    } else if (isInserting) {
      context.missing(_totalInvestedStrMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      balanceStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}balance_str'])!,
      totalInvestedStr: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}total_invested_str'])!,
    );
  }

  @override
  $WalletTableTable createAlias(String alias) {
    return $WalletTableTable(attachedDatabase, alias);
  }
}

class WalletEntry extends DataClass implements Insertable<WalletEntry> {
  /// Always 1 — enforces single-row semantics.
  final int id;
  final String balanceStr;
  final String totalInvestedStr;
  const WalletEntry(
      {required this.id,
      required this.balanceStr,
      required this.totalInvestedStr});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['balance_str'] = Variable<String>(balanceStr);
    map['total_invested_str'] = Variable<String>(totalInvestedStr);
    return map;
  }

  WalletTableCompanion toCompanion(bool nullToAbsent) {
    return WalletTableCompanion(
      id: Value(id),
      balanceStr: Value(balanceStr),
      totalInvestedStr: Value(totalInvestedStr),
    );
  }

  factory WalletEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletEntry(
      id: serializer.fromJson<int>(json['id']),
      balanceStr: serializer.fromJson<String>(json['balanceStr']),
      totalInvestedStr: serializer.fromJson<String>(json['totalInvestedStr']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'balanceStr': serializer.toJson<String>(balanceStr),
      'totalInvestedStr': serializer.toJson<String>(totalInvestedStr),
    };
  }

  WalletEntry copyWith(
          {int? id, String? balanceStr, String? totalInvestedStr}) =>
      WalletEntry(
        id: id ?? this.id,
        balanceStr: balanceStr ?? this.balanceStr,
        totalInvestedStr: totalInvestedStr ?? this.totalInvestedStr,
      );
  WalletEntry copyWithCompanion(WalletTableCompanion data) {
    return WalletEntry(
      id: data.id.present ? data.id.value : this.id,
      balanceStr:
          data.balanceStr.present ? data.balanceStr.value : this.balanceStr,
      totalInvestedStr: data.totalInvestedStr.present
          ? data.totalInvestedStr.value
          : this.totalInvestedStr,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletEntry(')
          ..write('id: $id, ')
          ..write('balanceStr: $balanceStr, ')
          ..write('totalInvestedStr: $totalInvestedStr')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, balanceStr, totalInvestedStr);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletEntry &&
          other.id == this.id &&
          other.balanceStr == this.balanceStr &&
          other.totalInvestedStr == this.totalInvestedStr);
}

class WalletTableCompanion extends UpdateCompanion<WalletEntry> {
  final Value<int> id;
  final Value<String> balanceStr;
  final Value<String> totalInvestedStr;
  const WalletTableCompanion({
    this.id = const Value.absent(),
    this.balanceStr = const Value.absent(),
    this.totalInvestedStr = const Value.absent(),
  });
  WalletTableCompanion.insert({
    this.id = const Value.absent(),
    required String balanceStr,
    required String totalInvestedStr,
  })  : balanceStr = Value(balanceStr),
        totalInvestedStr = Value(totalInvestedStr);
  static Insertable<WalletEntry> custom({
    Expression<int>? id,
    Expression<String>? balanceStr,
    Expression<String>? totalInvestedStr,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (balanceStr != null) 'balance_str': balanceStr,
      if (totalInvestedStr != null) 'total_invested_str': totalInvestedStr,
    });
  }

  WalletTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? balanceStr,
      Value<String>? totalInvestedStr}) {
    return WalletTableCompanion(
      id: id ?? this.id,
      balanceStr: balanceStr ?? this.balanceStr,
      totalInvestedStr: totalInvestedStr ?? this.totalInvestedStr,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (balanceStr.present) {
      map['balance_str'] = Variable<String>(balanceStr.value);
    }
    if (totalInvestedStr.present) {
      map['total_invested_str'] = Variable<String>(totalInvestedStr.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletTableCompanion(')
          ..write('id: $id, ')
          ..write('balanceStr: $balanceStr, ')
          ..write('totalInvestedStr: $totalInvestedStr')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WatchlistsTable watchlists = $WatchlistsTable(this);
  late final $WatchlistStocksTable watchlistStocks =
      $WatchlistStocksTable(this);
  late final $HoldingsTable holdings = $HoldingsTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $WalletTableTable walletTable = $WalletTableTable(this);
  late final WatchlistDao watchlistDao = WatchlistDao(this as AppDatabase);
  late final HoldingsDao holdingsDao = HoldingsDao(this as AppDatabase);
  late final OrdersDao ordersDao = OrdersDao(this as AppDatabase);
  late final WalletDao walletDao = WalletDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [watchlists, watchlistStocks, holdings, orders, walletTable];
}

typedef $$WatchlistsTableCreateCompanionBuilder = WatchlistsCompanion Function({
  required String id,
  required String name,
  required int sortOrder,
  Value<int> rowid,
});
typedef $$WatchlistsTableUpdateCompanionBuilder = WatchlistsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$WatchlistsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WatchlistsTable,
    WatchlistEntry,
    $$WatchlistsTableFilterComposer,
    $$WatchlistsTableOrderingComposer,
    $$WatchlistsTableCreateCompanionBuilder,
    $$WatchlistsTableUpdateCompanionBuilder> {
  $$WatchlistsTableTableManager(_$AppDatabase db, $WatchlistsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$WatchlistsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$WatchlistsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WatchlistsCompanion(
            id: id,
            name: name,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int sortOrder,
            Value<int> rowid = const Value.absent(),
          }) =>
              WatchlistsCompanion.insert(
            id: id,
            name: name,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
        ));
}

class $$WatchlistsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $WatchlistsTable> {
  $$WatchlistsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$WatchlistsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $WatchlistsTable> {
  $$WatchlistsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get sortOrder => $state.composableBuilder(
      column: $state.table.sortOrder,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$WatchlistStocksTableCreateCompanionBuilder = WatchlistStocksCompanion
    Function({
  required String watchlistId,
  required String symbol,
  required int position,
  Value<int> rowid,
});
typedef $$WatchlistStocksTableUpdateCompanionBuilder = WatchlistStocksCompanion
    Function({
  Value<String> watchlistId,
  Value<String> symbol,
  Value<int> position,
  Value<int> rowid,
});

class $$WatchlistStocksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WatchlistStocksTable,
    WatchlistStockEntry,
    $$WatchlistStocksTableFilterComposer,
    $$WatchlistStocksTableOrderingComposer,
    $$WatchlistStocksTableCreateCompanionBuilder,
    $$WatchlistStocksTableUpdateCompanionBuilder> {
  $$WatchlistStocksTableTableManager(
      _$AppDatabase db, $WatchlistStocksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$WatchlistStocksTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$WatchlistStocksTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> watchlistId = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WatchlistStocksCompanion(
            watchlistId: watchlistId,
            symbol: symbol,
            position: position,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String watchlistId,
            required String symbol,
            required int position,
            Value<int> rowid = const Value.absent(),
          }) =>
              WatchlistStocksCompanion.insert(
            watchlistId: watchlistId,
            symbol: symbol,
            position: position,
            rowid: rowid,
          ),
        ));
}

class $$WatchlistStocksTableFilterComposer
    extends FilterComposer<_$AppDatabase, $WatchlistStocksTable> {
  $$WatchlistStocksTableFilterComposer(super.$state);
  ColumnFilters<String> get watchlistId => $state.composableBuilder(
      column: $state.table.watchlistId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get symbol => $state.composableBuilder(
      column: $state.table.symbol,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get position => $state.composableBuilder(
      column: $state.table.position,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$WatchlistStocksTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $WatchlistStocksTable> {
  $$WatchlistStocksTableOrderingComposer(super.$state);
  ColumnOrderings<String> get watchlistId => $state.composableBuilder(
      column: $state.table.watchlistId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get symbol => $state.composableBuilder(
      column: $state.table.symbol,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get position => $state.composableBuilder(
      column: $state.table.position,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$HoldingsTableCreateCompanionBuilder = HoldingsCompanion Function({
  required String symbol,
  required int quantity,
  required String avgCostStr,
  Value<int> rowid,
});
typedef $$HoldingsTableUpdateCompanionBuilder = HoldingsCompanion Function({
  Value<String> symbol,
  Value<int> quantity,
  Value<String> avgCostStr,
  Value<int> rowid,
});

class $$HoldingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HoldingsTable,
    HoldingEntry,
    $$HoldingsTableFilterComposer,
    $$HoldingsTableOrderingComposer,
    $$HoldingsTableCreateCompanionBuilder,
    $$HoldingsTableUpdateCompanionBuilder> {
  $$HoldingsTableTableManager(_$AppDatabase db, $HoldingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$HoldingsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$HoldingsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> symbol = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> avgCostStr = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HoldingsCompanion(
            symbol: symbol,
            quantity: quantity,
            avgCostStr: avgCostStr,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String symbol,
            required int quantity,
            required String avgCostStr,
            Value<int> rowid = const Value.absent(),
          }) =>
              HoldingsCompanion.insert(
            symbol: symbol,
            quantity: quantity,
            avgCostStr: avgCostStr,
            rowid: rowid,
          ),
        ));
}

class $$HoldingsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableFilterComposer(super.$state);
  ColumnFilters<String> get symbol => $state.composableBuilder(
      column: $state.table.symbol,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get avgCostStr => $state.composableBuilder(
      column: $state.table.avgCostStr,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$HoldingsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $HoldingsTable> {
  $$HoldingsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get symbol => $state.composableBuilder(
      column: $state.table.symbol,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get avgCostStr => $state.composableBuilder(
      column: $state.table.avgCostStr,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  required String id,
  required String symbol,
  required String side,
  required int quantity,
  required String executedPriceStr,
  required String totalValueStr,
  required int timestampMs,
  Value<int> rowid,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<String> id,
  Value<String> symbol,
  Value<String> side,
  Value<int> quantity,
  Value<String> executedPriceStr,
  Value<String> totalValueStr,
  Value<int> timestampMs,
  Value<int> rowid,
});

class $$OrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrdersTable,
    OrderEntry,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder> {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$OrdersTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$OrdersTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<String> side = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> executedPriceStr = const Value.absent(),
            Value<String> totalValueStr = const Value.absent(),
            Value<int> timestampMs = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrdersCompanion(
            id: id,
            symbol: symbol,
            side: side,
            quantity: quantity,
            executedPriceStr: executedPriceStr,
            totalValueStr: totalValueStr,
            timestampMs: timestampMs,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String symbol,
            required String side,
            required int quantity,
            required String executedPriceStr,
            required String totalValueStr,
            required int timestampMs,
            Value<int> rowid = const Value.absent(),
          }) =>
              OrdersCompanion.insert(
            id: id,
            symbol: symbol,
            side: side,
            quantity: quantity,
            executedPriceStr: executedPriceStr,
            totalValueStr: totalValueStr,
            timestampMs: timestampMs,
            rowid: rowid,
          ),
        ));
}

class $$OrdersTableFilterComposer
    extends FilterComposer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get symbol => $state.composableBuilder(
      column: $state.table.symbol,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get side => $state.composableBuilder(
      column: $state.table.side,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get executedPriceStr => $state.composableBuilder(
      column: $state.table.executedPriceStr,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get totalValueStr => $state.composableBuilder(
      column: $state.table.totalValueStr,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get timestampMs => $state.composableBuilder(
      column: $state.table.timestampMs,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$OrdersTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get symbol => $state.composableBuilder(
      column: $state.table.symbol,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get side => $state.composableBuilder(
      column: $state.table.side,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get quantity => $state.composableBuilder(
      column: $state.table.quantity,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get executedPriceStr => $state.composableBuilder(
      column: $state.table.executedPriceStr,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get totalValueStr => $state.composableBuilder(
      column: $state.table.totalValueStr,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get timestampMs => $state.composableBuilder(
      column: $state.table.timestampMs,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$WalletTableTableCreateCompanionBuilder = WalletTableCompanion
    Function({
  Value<int> id,
  required String balanceStr,
  required String totalInvestedStr,
});
typedef $$WalletTableTableUpdateCompanionBuilder = WalletTableCompanion
    Function({
  Value<int> id,
  Value<String> balanceStr,
  Value<String> totalInvestedStr,
});

class $$WalletTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WalletTableTable,
    WalletEntry,
    $$WalletTableTableFilterComposer,
    $$WalletTableTableOrderingComposer,
    $$WalletTableTableCreateCompanionBuilder,
    $$WalletTableTableUpdateCompanionBuilder> {
  $$WalletTableTableTableManager(_$AppDatabase db, $WalletTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$WalletTableTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$WalletTableTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> balanceStr = const Value.absent(),
            Value<String> totalInvestedStr = const Value.absent(),
          }) =>
              WalletTableCompanion(
            id: id,
            balanceStr: balanceStr,
            totalInvestedStr: totalInvestedStr,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String balanceStr,
            required String totalInvestedStr,
          }) =>
              WalletTableCompanion.insert(
            id: id,
            balanceStr: balanceStr,
            totalInvestedStr: totalInvestedStr,
          ),
        ));
}

class $$WalletTableTableFilterComposer
    extends FilterComposer<_$AppDatabase, $WalletTableTable> {
  $$WalletTableTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get balanceStr => $state.composableBuilder(
      column: $state.table.balanceStr,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get totalInvestedStr => $state.composableBuilder(
      column: $state.table.totalInvestedStr,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$WalletTableTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $WalletTableTable> {
  $$WalletTableTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get balanceStr => $state.composableBuilder(
      column: $state.table.balanceStr,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get totalInvestedStr => $state.composableBuilder(
      column: $state.table.totalInvestedStr,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WatchlistsTableTableManager get watchlists =>
      $$WatchlistsTableTableManager(_db, _db.watchlists);
  $$WatchlistStocksTableTableManager get watchlistStocks =>
      $$WatchlistStocksTableTableManager(_db, _db.watchlistStocks);
  $$HoldingsTableTableManager get holdings =>
      $$HoldingsTableTableManager(_db, _db.holdings);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$WalletTableTableTableManager get walletTable =>
      $$WalletTableTableTableManager(_db, _db.walletTable);
}
