import 'package:decimal/decimal.dart';

/// The canonical list of 10 NSE stocks used throughout the app.
///
/// All string keys, starting prices, and company names are defined here.
/// No stock symbol should be hardcoded anywhere else.
class StockConstants {
  StockConstants._();

  /// Initial wallet balance for new users (₹10,00,000).
  static final Decimal initialWalletBalance = Decimal.parse('1000000.00');

  /// Default tick interval in milliseconds (1 tick / stock / second).
  static const int defaultTickIntervalMs = 1000;

  /// All 10 available stock symbols in display order.
  static const List<String> allSymbols = [
    'RELIANCE',
    'TCS',
    'INFY',
    'HDFCBANK',
    'ICICIBANK',
    'SBIN',
    'ITC',
    'LT',
    'BHARTIARTL',
    'AXISBANK',
  ];

  /// Company name for each symbol.
  static const Map<String, String> companyNames = {
    'RELIANCE': 'Reliance Industries',
    'TCS': 'Tata Consultancy Services',
    'INFY': 'Infosys',
    'HDFCBANK': 'HDFC Bank',
    'ICICIBANK': 'ICICI Bank',
    'SBIN': 'State Bank of India',
    'ITC': 'ITC Limited',
    'LT': 'Larsen & Toubro',
    'BHARTIARTL': 'Bharti Airtel',
    'AXISBANK': 'Axis Bank',
  };

  /// Sector for each symbol.
  static const Map<String, String> sectors = {
    'RELIANCE': 'Energy',
    'TCS': 'IT',
    'INFY': 'IT',
    'HDFCBANK': 'Banking',
    'ICICIBANK': 'Banking',
    'SBIN': 'Banking',
    'ITC': 'FMCG',
    'LT': 'Infrastructure',
    'BHARTIARTL': 'Telecom',
    'AXISBANK': 'Banking',
  };

  /// Exact live NSE stock prices.
  static const Map<String, String> startingPrices = {
    'RELIANCE': '1311.60',
    'TCS': '2294.60',
    'INFY': '1120.40',
    'HDFCBANK': '730.15',
    'ICICIBANK': '1417.90',
    'SBIN': '1041.40',
    'ITC': '269.55',
    'LT': '4090.90',
    'BHARTIARTL': '1947.00',
    'AXISBANK': '1243.80',
  };

  /// Exact previous close prices on NSE.
  static const Map<String, String> previousClosePrices = {
    'RELIANCE': '1313.20',
    'TCS': '2298.00',
    'INFY': '1130.00',
    'HDFCBANK': '725.05',
    'ICICIBANK': '1411.90',
    'SBIN': '1048.00',
    'ITC': '271.65',
    'LT': '4081.00',
    'BHARTIARTL': '1941.70',
    'AXISBANK': '1251.00',
  };

  /// Returns the company name for a symbol, with a safe fallback.
  static String nameFor(String symbol) =>
      companyNames[symbol] ?? symbol;

  /// Returns the sector for a symbol, with a safe fallback.
  static String sectorFor(String symbol) =>
      sectors[symbol] ?? 'Equity';

  /// Returns the starting Decimal price for a symbol.
  static Decimal startingPriceFor(String symbol) =>
      Decimal.parse(startingPrices[symbol] ?? '1000.00');

  /// Returns the previous close Decimal price for a symbol.
  static Decimal previousCloseFor(String symbol) =>
      Decimal.parse(previousClosePrices[symbol] ?? startingPrices[symbol] ?? '1000.00');
}
