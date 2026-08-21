import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/price_tick.dart';
import '../../data/datasources/mock/mock_market_feed.dart';
import '../../core/constants/stock_constants.dart';

/// The single global source of truth for live market prices.
///
/// - Subscribes to [MockMarketFeed] on construction.
/// - Holds the latest [PriceTick] for each symbol in O(1) map.
/// - [Selector] widgets subscribe to individual symbols to avoid full rebuilds.
class MarketViewModel extends ChangeNotifier {
  MarketViewModel(this._feed) {
    _feed.start();
    _sub = _feed.ticks.listen(_onTick);
  }

  final MockMarketFeed _feed;
  late final StreamSubscription<PriceTick> _sub;

  final Map<String, PriceTick> _ticks = {};

  /// Returns the latest tick for [symbol], or null if not yet received.
  PriceTick? tickFor(String symbol) => _ticks[symbol];

  /// All current ticks in symbol order.
  List<PriceTick> get allTicks =>
      StockConstants.allSymbols.map((s) => _ticks[s]).whereType<PriceTick>().toList();

  void _onTick(PriceTick tick) {
    _ticks[tick.symbol] = tick;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub.cancel();
    _feed.dispose();
    super.dispose();
  }
}
