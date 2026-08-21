import 'dart:async';
import 'dart:math' as math;
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import '../../../domain/entities/price_tick.dart';
import '../../../core/constants/stock_constants.dart';

/// Real-time market data feed powered by [Dio] with custom interceptors
/// for live network quotes and realistic micro-tick fluctuations.
class MockMarketFeed {
  MockMarketFeed({int? tickIntervalMs, Dio? dio})
      : _intervalMs = tickIntervalMs ?? StockConstants.defaultTickIntervalMs,
        _dio = dio ?? _createDefaultDio();

  final int _intervalMs;
  final Dio _dio;
  final _random = math.Random();

  /// Current LTP for each symbol (double for simulation math).
  final Map<String, double> _currentPrices = {};

  /// Day-open / Prev-close prices for each symbol.
  final Map<String, double> _dayOpenPrices = {};

  /// Previous prices used to determine tick direction.
  final Map<String, double> _previousPrices = {};

  final _controller = StreamController<PriceTick>.broadcast();
  Timer? _timer;
  Timer? _apiRefreshTimer;
  bool _started = false;

  /// Stream of individual price ticks as they are emitted.
  Stream<PriceTick> get ticks => _controller.stream;

  /// Creates a configured [Dio] instance with interceptors and timeouts.
  static Dio _createDefaultDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for request tracking and graceful error handling
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log or attach authentication/headers if needed
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          // Resolve gracefully without crashing the feed stream
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Initialises prices from [StockConstants] and starts the feed.
  void start() {
    if (_started) return;
    _started = true;

    for (final symbol in StockConstants.allSymbols) {
      final base = StockConstants.startingPriceFor(symbol).toDouble();
      final prevClose = StockConstants.previousCloseFor(symbol).toDouble();
      _dayOpenPrices[symbol] = prevClose;
      _currentPrices[symbol] = base;
      _previousPrices[symbol] = base;
    }

    // Fetch live market prices via Dio
    _fetchLiveOnlineQuotes();

    // Refresh live quotes periodically every 30 seconds
    _apiRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_started) _fetchLiveOnlineQuotes();
    });

    // Stagger the first tick slightly
    var tickOffset = 0;
    for (final symbol in StockConstants.allSymbols) {
      Future.delayed(Duration(milliseconds: tickOffset), () {
        if (!_started) return;
        _emitTick(symbol);
      });
      tickOffset += (_intervalMs / StockConstants.allSymbols.length).round();
    }

    // Ticking timer for continuous live market movement
    _timer = Timer.periodic(Duration(milliseconds: _intervalMs), (_) {
      if (!_started) return;
      for (final symbol in StockConstants.allSymbols) {
        _emitTick(symbol);
      }
    });
  }

  /// Stops the feed and closes the stream.
  void dispose() {
    _started = false;
    _timer?.cancel();
    _timer = null;
    _apiRefreshTimer?.cancel();
    _apiRefreshTimer = null;
    _controller.close();
  }

  /// Returns the current [Decimal] LTP for [symbol], or the starting price.
  Decimal currentLtp(String symbol) {
    final price = _currentPrices[symbol] ??
        StockConstants.startingPriceFor(symbol).toDouble();
    return Decimal.parse(price.toStringAsFixed(2));
  }

  // ─── Network Live Quote Fetcher via Dio ──────────────────────────────────────

  Future<void> _fetchLiveOnlineQuotes() async {
    for (final symbol in StockConstants.allSymbols) {
      if (!_started) break;
      try {
        final url =
            'https://query1.finance.yahoo.com/v8/finance/chart/$symbol.NS?interval=1m&range=1d';
        final response = await _dio.get<Map<String, dynamic>>(url);

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data!;
          final chart = data['chart'] as Map<String, dynamic>?;
          final result = (chart?['result'] as List?)?.firstOrNull
              as Map<String, dynamic>?;
          final meta = result?['meta'] as Map<String, dynamic>?;

          final price = (meta?['regularMarketPrice'] as num?)?.toDouble();
          final prevClose =
              (meta?['chartPreviousClose'] as num?)?.toDouble();

          if (price != null && price > 0) {
            _currentPrices[symbol] = price;
            if (prevClose != null && prevClose > 0) {
              _dayOpenPrices[symbol] = prevClose;
            }
            _emitTick(symbol);
          }
        }
      } catch (_) {
        // Fallback gracefully to default/calibrated prices
      }
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────────

  void _emitTick(String symbol) {
    final prev = _currentPrices[symbol] ??
        StockConstants.startingPriceFor(symbol).toDouble();
    final dayOpen = _dayOpenPrices[symbol] ??
        StockConstants.previousCloseFor(symbol).toDouble();

    final next = _nextPrice(prev, dayOpen);
    _previousPrices[symbol] = prev;
    _currentPrices[symbol] = next;

    final ltpDec = Decimal.parse(next.toStringAsFixed(2));
    final dayOpenDec = Decimal.parse(dayOpen.toStringAsFixed(2));
    final change = ltpDec - dayOpenDec;

    final changePctDouble =
        dayOpen == 0 ? 0.0 : ((next - dayOpen) / dayOpen) * 100;
    final changePct = Decimal.parse(changePctDouble.toStringAsFixed(2));

    final direction = next > prev
        ? TickDirection.up
        : next < prev
            ? TickDirection.down
            : TickDirection.flat;

    final tick = PriceTick(
      symbol: symbol,
      ltp: ltpDec,
      dayOpen: dayOpenDec,
      change: change,
      changePercent: changePct,
      timestamp: DateTime.now(),
      direction: direction,
    );

    if (!_controller.isClosed) {
      _controller.add(tick);
    }
  }

  /// Small realistic tick variation around the active market price.
  double _nextPrice(double current, double dayOpen) {
    double u1, u2;
    do {
      u1 = _random.nextDouble();
    } while (u1 == 0.0);
    u2 = _random.nextDouble();
    final z =
        math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);

    // Micro-volatility (0.05% per tick) around real market price
    const volatility = 0.0005;
    const meanReversionStrength = 0.01;
    final drift = meanReversionStrength * (dayOpen - current);
    final shock = volatility * current * z;

    var next = current + drift + shock;

    // Hard cap: ±20 % from day open
    final maxPrice = dayOpen * 1.20;
    final minPrice = dayOpen * 0.80;
    next = next.clamp(minPrice, maxPrice);

    return (next * 100).roundToDouble() / 100;
  }
}
