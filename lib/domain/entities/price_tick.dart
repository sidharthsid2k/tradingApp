import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// Direction of a price movement relative to the previous tick.
enum TickDirection { up, down, flat }

/// A single price tick emitted by the market feed for one stock.
class PriceTick extends Equatable {
  const PriceTick({
    required this.symbol,
    required this.ltp,
    required this.dayOpen,
    required this.change,
    required this.changePercent,
    required this.timestamp,
    required this.direction,
  });

  final String symbol;

  /// Last Traded Price.
  final Decimal ltp;

  /// Price at market open (session-level; resets on app restart).
  final Decimal dayOpen;

  /// Absolute change from day open (ltp − dayOpen).
  final Decimal change;

  /// Percentage change from day open.
  final Decimal changePercent;

  final DateTime timestamp;
  final TickDirection direction;

  bool get isGain => direction == TickDirection.up || change > Decimal.zero;
  bool get isLoss => direction == TickDirection.down || change < Decimal.zero;

  @override
  List<Object?> get props =>
      [symbol, ltp, change, changePercent, timestamp, direction];
}
