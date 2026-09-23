import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Whether an order is a buy or sell.
enum OrderSide { buy, sell }

/// Type of order: immediate Market order or price-targeted Limit order.
enum OrderType { market, limit }

/// Lifecycle status of an order.
enum OrderStatus { pending, executed, cancelled }

/// Trigger condition for pending limit order matching against LTP.
enum TriggerDirection { gte, lte }

/// Represents an order (pending limit order, executed trade, or cancelled).
class Order extends Equatable {
  const Order({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    this.orderType = OrderType.market,
    this.status = OrderStatus.executed,
    this.limitPrice,
    this.executedPrice,
    required this.totalValue,
    required this.timestamp,
    this.triggerDirection,
  });

  final String id;
  final String symbol;
  final OrderSide side;
  final int quantity;
  final OrderType orderType;
  final OrderStatus status;

  /// Target price set by the user for Limit orders.
  final Decimal? limitPrice;

  /// Price at which the order was executed (null if pending).
  final Decimal? executedPrice;

  /// Total value = quantity × (executedPrice ?? limitPrice).
  final Decimal totalValue;

  final DateTime timestamp;

  /// Condition under which this order triggers when live ticks arrive.
  final TriggerDirection? triggerDirection;

  bool get isPending => status == OrderStatus.pending;
  bool get isExecuted => status == OrderStatus.executed;
  bool get isCancelled => status == OrderStatus.cancelled;

  Order copyWith({
    String? id,
    String? symbol,
    OrderSide? side,
    int? quantity,
    OrderType? orderType,
    OrderStatus? status,
    Decimal? limitPrice,
    Decimal? executedPrice,
    Decimal? totalValue,
    DateTime? timestamp,
    TriggerDirection? triggerDirection,
  }) {
    return Order(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      side: side ?? this.side,
      quantity: quantity ?? this.quantity,
      orderType: orderType ?? this.orderType,
      status: status ?? this.status,
      limitPrice: limitPrice ?? this.limitPrice,
      executedPrice: executedPrice ?? this.executedPrice,
      totalValue: totalValue ?? this.totalValue,
      timestamp: timestamp ?? this.timestamp,
      triggerDirection: triggerDirection ?? this.triggerDirection,
    );
  }

  @override
  List<Object?> get props => [
        id,
        symbol,
        side,
        quantity,
        orderType,
        status,
        limitPrice,
        executedPrice,
        totalValue,
        timestamp,
        triggerDirection,
      ];
}
