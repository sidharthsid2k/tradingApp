import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/entities/holding.dart';
import '../../domain/entities/price_tick.dart';
import '../../domain/usecases/order/place_buy_order_usecase.dart';
import '../../domain/usecases/order/place_sell_order_usecase.dart';
import '../../domain/repositories/i_wallet_repository.dart';
import '../../domain/repositories/i_holdings_repository.dart';
import '../../core/errors/app_exception.dart';
import '../../core/constants/app_strings.dart';
import 'holdings_viewmodel.dart';

enum OrderSideUi { buy, sell }
enum OrderTypeUi { limit, market }

/// ViewModel for the Buy/Sell order ticket.
///
/// Created fresh per-page. Validates inputs against wallet and holdings,
/// supports both Market orders and Limit orders with custom price,
/// then delegates to use-cases for execution.
class OrderViewModel extends ChangeNotifier {
  OrderViewModel({
    required String symbol,
    required OrderSideUi initialSide,
    required PlaceBuyOrderUseCase placeBuyOrder,
    required PlaceSellOrderUseCase placeSellOrder,
    required IWalletRepository walletRepo,
    required IHoldingsRepository holdingsRepo,
  })  : _symbol = symbol,
        _side = initialSide,
        _placeBuyOrder = placeBuyOrder,
        _placeSellOrder = placeSellOrder,
        _walletRepo = walletRepo,
        _holdingsRepo = holdingsRepo {
    _load();
  }

  final String _symbol;
  final PlaceBuyOrderUseCase _placeBuyOrder;
  final PlaceSellOrderUseCase _placeSellOrder;
  final IWalletRepository _walletRepo;
  final IHoldingsRepository _holdingsRepo;

  OrderSideUi _side;
  OrderTypeUi _orderType = OrderTypeUi.limit;
  String _quantityText = '';
  String _priceText = '';
  Wallet? _wallet;
  Holding? _holding;
  PriceTick? _latestTick;
  String? _validationError;
  bool _isSubmitting = false;
  Order? _completedOrder;

  // ─── Getters ─────────────────────────────────────────────────────────────

  String get symbol => _symbol;
  OrderSideUi get side => _side;
  OrderTypeUi get orderType => _orderType;
  String get quantityText => _quantityText;
  String get priceText => _priceText;
  Wallet? get wallet => _wallet;
  Holding? get holding => _holding;
  PriceTick? get latestTick => _latestTick;
  String? get validationError => _validationError;
  bool get isSubmitting => _isSubmitting;
  Order? get completedOrder => _completedOrder;

  Decimal get ltp => _latestTick?.ltp ?? Decimal.zero;

  /// Computed holding view if the user already purchased this stock.
  HoldingView? get holdingView {
    final h = _holding;
    if (h == null || h.quantity <= 0) return null;
    final currentLtp = ltp > Decimal.zero ? ltp : h.avgCost;
    final ltpDouble = double.parse(currentLtp.toStringAsFixed(4));
    final avgDouble = double.parse(h.avgCost.toStringAsFixed(4));
    final qty = h.quantity;

    final currentValueDouble = ltpDouble * qty;
    final investedDouble = avgDouble * qty;
    final pnlDouble = currentValueDouble - investedDouble;
    final pnlPctDouble =
        investedDouble == 0 ? 0.0 : (pnlDouble / investedDouble) * 100;

    return HoldingView(
      holding: h,
      ltp: currentLtp,
      currentValue: Decimal.parse(currentValueDouble.toStringAsFixed(2)),
      pnl: Decimal.parse(pnlDouble.toStringAsFixed(2)),
      pnlPercent: Decimal.parse(pnlPctDouble.toStringAsFixed(2)),
    );
  }

  /// Effective price per share: custom limit price if limit order, or live LTP if market order.
  Decimal get effectivePrice {
    if (_orderType == OrderTypeUi.market) return ltp;
    final parsed = _parsePrice();
    return (parsed != null && parsed > Decimal.zero) ? parsed : ltp;
  }

  /// Projected order value = qty × effectivePrice.
  Decimal get projectedValue {
    final qty = _parseQty();
    if (qty == null || qty <= 0) return Decimal.zero;
    final price = _orderType == OrderTypeUi.market
        ? ltp
        : (_parsePrice() ?? Decimal.zero);
    return price * Decimal.fromInt(qty);
  }

  bool get canSubmit =>
      !_isSubmitting &&
      _validationError == null &&
      _parseQty() != null &&
      _parseQty()! > 0 &&
      effectivePrice > Decimal.zero &&
      (_orderType == OrderTypeUi.market || (_parsePrice() != null && _parsePrice()! > Decimal.zero));

  // ─── Setters ─────────────────────────────────────────────────────────────

  void setSide(OrderSideUi side) {
    _side = side;
    _validationError = null;
    _validateSilent();
    notifyListeners();
  }

  void setOrderType(OrderTypeUi type) {
    _orderType = type;
    if (type == OrderTypeUi.limit && _priceText.isEmpty && ltp > Decimal.zero) {
      _priceText = ltp.toStringAsFixed(2);
    }
    _validateSilent();
    notifyListeners();
  }

  void toggleOrderType() {
    setOrderType(
      _orderType == OrderTypeUi.limit ? OrderTypeUi.market : OrderTypeUi.limit,
    );
  }

  void setQuantity(String text) {
    _quantityText = text;
    _validateSilent();
    notifyListeners();
  }

  void setPrice(String text) {
    _priceText = text;
    _validateSilent();
    notifyListeners();
  }

  /// Called by the UI on every tick from [MarketViewModel].
  void updateTick(PriceTick? tick) {
    _latestTick = tick;
    // Auto-fill initial limit price if empty and tick arrives
    if (_orderType == OrderTypeUi.limit && _priceText.isEmpty && tick != null) {
      _priceText = tick.ltp.toStringAsFixed(2);
    }
    _validateSilent();
    notifyListeners();
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<Order?> submit() async {
    _validationError = _validate();
    if (_validationError != null) {
      notifyListeners();
      return null;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final qty = _parseQty()!;
      final priceToExecute = effectivePrice;

      final domainOrderType = _orderType == OrderTypeUi.limit
          ? OrderType.limit
          : OrderType.market;

      Order order;
      if (_side == OrderSideUi.buy) {
        order = await _placeBuyOrder(
          symbol: _symbol,
          quantity: qty,
          price: priceToExecute,
          orderType: domainOrderType,
          currentLtp: ltp,
        );
      } else {
        order = await _placeSellOrder(
          symbol: _symbol,
          quantity: qty,
          price: priceToExecute,
          orderType: domainOrderType,
          currentLtp: ltp,
        );
      }
      _completedOrder = order;
      return order;
    } on AppException catch (e) {
      _validationError = e.message;
      return null;
    } catch (e) {
      _validationError = e.toString();
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  Future<void> _load() async {
    _wallet = await _walletRepo.get();
    _holding = await _holdingsRepo.getBySymbol(_symbol);
    notifyListeners();
  }

  int? _parseQty() {
    final text = _quantityText.trim();
    if (text.isEmpty) return null;
    final n = int.tryParse(text);
    return (n != null && n > 0) ? n : null;
  }

  Decimal? _parsePrice() {
    final text = _priceText.trim();
    if (text.isEmpty) return null;
    final d = double.tryParse(text);
    if (d == null || d <= 0) return null;
    try {
      return Decimal.parse(text);
    } catch (_) {
      return null;
    }
  }

  /// Validate without surfacing error on empty inputs (called on every text/tick change).
  void _validateSilent() {
    _validationError = _validate();
  }

  String? _validate() {
    final qty = _parseQty();
    // Do not show an error banner when quantity is not yet entered; the button is already disabled
    if (qty == null || qty <= 0) {
      return null;
    }

    if (_orderType == OrderTypeUi.limit) {
      final price = _parsePrice();
      if (price == null || price <= Decimal.zero) {
        if (_priceText.trim().isNotEmpty) {
          return AppStrings.errInvalidPrice;
        }
        return null;
      }
    }

    final price = effectivePrice;
    if (price <= Decimal.zero) {
      return null;
    }

    if (_side == OrderSideUi.buy) {
      final required = price * Decimal.fromInt(qty);
      final balance = _wallet?.balance ?? Decimal.zero;
      if (required > balance) return AppStrings.errInsufficientBalance;
    } else {
      final held = _holding?.quantity ?? 0;
      if (held == 0) return AppStrings.errNoHoldings;
      if (qty > held) return AppStrings.errInsufficientQty;
    }
    return null;
  }
}
