import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Whether an order is a buy or sell.
enum OrderSide { buy, sell }

/// A completed (simulated) market order.
class Order extends Equatable {
  const Order({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.executedPrice,
    required this.totalValue,
    required this.timestamp,
  });

  final String id;
  final String symbol;
  final OrderSide side;
  final int quantity;

  /// Price at which the order was executed (LTP at submit time).
  final Decimal executedPrice;

  /// Total value = quantity × executedPrice.
  final Decimal totalValue;

  final DateTime timestamp;

  @override
  List<Object?> get props => [id, symbol, side, quantity, executedPrice, timestamp];
}
