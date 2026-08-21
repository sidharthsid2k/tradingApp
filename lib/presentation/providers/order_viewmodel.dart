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

enum OrderSideUi { buy, sell }

/// ViewModel for the Buy/Sell order ticket.
///
/// Created fresh per-page. Validates inputs against wallet and holdings,
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
  String _quantityText = '';
  Wallet? _wallet;
  Holding? _holding;
  PriceTick? _latestTick;
  String? _validationError;
  bool _isSubmitting = false;
  Order? _completedOrder;

  // ─── Getters ─────────────────────────────────────────────────────────────

  String get symbol => _symbol;
  OrderSideUi get side => _side;
  String get quantityText => _quantityText;
  Wallet? get wallet => _wallet;
  Holding? get holding => _holding;
  PriceTick? get latestTick => _latestTick;
  String? get validationError => _validationError;
  bool get isSubmitting => _isSubmitting;
  Order? get completedOrder => _completedOrder;

  Decimal get ltp => _latestTick?.ltp ?? Decimal.zero;

  /// Projected order value = qty × LTP.
  Decimal get projectedValue {
    final qty = _parseQty();
    if (qty == null || qty <= 0) return Decimal.zero;
    return ltp * Decimal.fromInt(qty);
  }

  bool get canSubmit =>
      !_isSubmitting &&
      _validationError == null &&
      _parseQty() != null &&
      _parseQty()! > 0 &&
      ltp > Decimal.zero;

  // ─── Setters ─────────────────────────────────────────────────────────────

  void setSide(OrderSideUi side) {
    _side = side;
    _validationError = null;
    notifyListeners();
  }

  void setQuantity(String text) {
    _quantityText = text;
    _validateSilent();
    notifyListeners();
  }

  /// Called by the UI on every tick from [MarketViewModel].
  void updateTick(PriceTick? tick) {
    _latestTick = tick;
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
      final currentLtp = ltp;

      Order order;
      if (_side == OrderSideUi.buy) {
        order = await _placeBuyOrder(
          symbol: _symbol,
          quantity: qty,
          ltp: currentLtp,
        );
      } else {
        order = await _placeSellOrder(
          symbol: _symbol,
          quantity: qty,
          ltp: currentLtp,
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

  /// Validate without surfacing error (called on every text/tick change).
  void _validateSilent() {
    // Only show error after user has entered something
    if (_quantityText.isEmpty) {
      _validationError = null;
    } else {
      _validationError = _validate();
    }
  }

  String? _validate() {
    final qty = _parseQty();
    if (qty == null) return AppStrings.errInvalidQty;
    if (qty <= 0) return AppStrings.errQtyPositive;

    if (_side == OrderSideUi.buy) {
      final required = ltp * Decimal.fromInt(qty);
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
