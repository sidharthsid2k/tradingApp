import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// A current stock position in the user's portfolio.
class Holding extends Equatable {
  const Holding({
    required this.symbol,
    required this.quantity,
    required this.avgCost,
  });

  final String symbol;
  final int quantity;

  /// Average buy cost per share — stored as Decimal for precision.
  final Decimal avgCost;

  /// Total amount invested in this holding.
  Decimal get totalInvested => avgCost * Decimal.fromInt(quantity);

  Holding copyWith({int? quantity, Decimal? avgCost}) => Holding(
        symbol: symbol,
        quantity: quantity ?? this.quantity,
        avgCost: avgCost ?? this.avgCost,
      );

  @override
  List<Object?> get props => [symbol, quantity, avgCost];
}
