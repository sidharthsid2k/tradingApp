import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/stock_constants.dart';

/// Immutable description of a tradable stock instrument.
class Stock extends Equatable {
  const Stock({
    required this.symbol,
    required this.companyName,
    required this.sector,
    required this.basePrice,
  });

  final String symbol;
  final String companyName;
  final String sector;
  final Decimal basePrice;

  /// Creates a [Stock] from the [StockConstants] registry.
  factory Stock.fromSymbol(String symbol) => Stock(
        symbol: symbol,
        companyName: StockConstants.nameFor(symbol),
        sector: StockConstants.sectorFor(symbol),
        basePrice: StockConstants.startingPriceFor(symbol),
      );

  @override
  List<Object?> get props => [symbol];
}
