import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/holding.dart';
import '../../domain/usecases/holdings/get_holdings_usecase.dart';
import '../../domain/usecases/holdings/delete_holding_usecase.dart';
import '../../domain/entities/price_tick.dart';
import '../../core/constants/app_strings.dart';

/// How the holdings list is sorted.
enum HoldingsSortOrder { pnlDesc, pnlAsc, symbol, value }

/// Computed view of a holding with live P&L at a given LTP.
class HoldingView {
  const HoldingView({
    required this.holding,
    required this.ltp,
    required this.currentValue,
    required this.pnl,
    required this.pnlPercent,
  });

  final Holding holding;
  final Decimal ltp;
  final Decimal currentValue;
  final Decimal pnl;
  final Decimal pnlPercent;

  String get symbol => holding.symbol;
  int get quantity => holding.quantity;
  Decimal get avgCost => holding.avgCost;
  Decimal get totalInvested => holding.totalInvested;
}

/// ViewModel for the Holdings screen.
///
/// Holdings are loaded from DB; live P&L is computed from the [MarketViewModel]
/// ticks that are passed in via [refreshWithTicks].
class HoldingsViewModel extends ChangeNotifier {
  HoldingsViewModel(
    GetHoldingsUseCase getHoldings, {
    DeleteHoldingUseCase? deleteHolding,
  })  : _getHoldings = getHoldings,
        _deleteHolding = deleteHolding {
    loadAll();
  }

  final GetHoldingsUseCase _getHoldings;
  final DeleteHoldingUseCase? _deleteHolding;

  List<Holding> _holdings = [];
  Map<String, PriceTick> _ticks = {};
  HoldingsSortOrder _sortOrder = HoldingsSortOrder.pnlDesc;
  bool _isLoading = false;

  HoldingsSortOrder get sortOrder => _sortOrder;
  bool get isLoading => _isLoading;
  bool get isEmpty => _holdings.isEmpty;

  // ─── Sort label map ──────────────────────────────────────────────────────

  static const sortLabels = {
    HoldingsSortOrder.pnlDesc: AppStrings.sortByPnl,
    HoldingsSortOrder.pnlAsc: AppStrings.sortByPnl,
    HoldingsSortOrder.symbol: AppStrings.sortBySymbol,
    HoldingsSortOrder.value: AppStrings.sortByValue,
  };

  // ─── Computed list ───────────────────────────────────────────────────────

  List<HoldingView> get holdingViews {
    final views = _holdings.map((h) {
      final tick = _ticks[h.symbol];
      final ltp = tick?.ltp ?? h.avgCost;
      // Use double arithmetic for P&L to avoid Decimal/Rational type confusion
      final ltpDouble = double.parse(ltp.toStringAsFixed(4));
      final avgDouble = double.parse(h.avgCost.toStringAsFixed(4));
      final qty = h.quantity;

      final currentValueDouble = ltpDouble * qty;
      final investedDouble = avgDouble * qty;
      final pnlDouble = currentValueDouble - investedDouble;
      final pnlPctDouble = investedDouble == 0 ? 0.0 : (pnlDouble / investedDouble) * 100;

      return HoldingView(
        holding: h,
        ltp: ltp,
        currentValue: Decimal.parse(currentValueDouble.toStringAsFixed(2)),
        pnl: Decimal.parse(pnlDouble.toStringAsFixed(2)),
        pnlPercent: Decimal.parse(pnlPctDouble.toStringAsFixed(2)),
      );
    }).toList();

    return _sortViews(views);
  }

  // ─── Aggregate totals ────────────────────────────────────────────────────

  Decimal get totalInvested => _holdings.fold(
      Decimal.zero, (sum, h) => sum + h.totalInvested);

  Decimal get totalCurrentValue => holdingViews.fold(
      Decimal.zero, (sum, v) => sum + v.currentValue);

  Decimal get totalPnl => totalCurrentValue - totalInvested;

  Decimal get totalPnlPercent {
    final invested = double.parse(totalInvested.toStringAsFixed(4));
    if (invested == 0) return Decimal.zero;
    final pnl = double.parse(totalPnl.toStringAsFixed(4));
    final pct = (pnl / invested) * 100;
    return Decimal.parse(pct.toStringAsFixed(2));
  }

  // ─── Load / refresh ──────────────────────────────────────────────────────

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      _holdings = await _getHoldings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called by the UI whenever market ticks arrive, to recompute P&L.
  void refreshWithTicks(Map<String, PriceTick> ticks) {
    _ticks = ticks;
    notifyListeners();
  }

  Future<void> deleteHolding(String symbol) async {
    if (_deleteHolding != null) {
      await _deleteHolding.call(symbol);
      await loadAll();
    }
  }

  Future<void> clearAllHoldings() async {
    if (_deleteHolding != null) {
      await _deleteHolding.clearAll();
      await loadAll();
    }
  }

  void setSortOrder(HoldingsSortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  List<HoldingView> _sortViews(List<HoldingView> views) {
    final sorted = List<HoldingView>.from(views);
    switch (_sortOrder) {
      case HoldingsSortOrder.pnlDesc:
        sorted.sort((a, b) => b.pnl.compareTo(a.pnl));
      case HoldingsSortOrder.pnlAsc:
        sorted.sort((a, b) => a.pnl.compareTo(b.pnl));
      case HoldingsSortOrder.symbol:
        sorted.sort((a, b) => a.symbol.compareTo(b.symbol));
      case HoldingsSortOrder.value:
        sorted.sort((a, b) => b.currentValue.compareTo(a.currentValue));
    }
    return sorted;
  }
}
