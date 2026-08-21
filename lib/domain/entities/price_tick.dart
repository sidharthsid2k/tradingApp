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

  /// Net gain for the session (LTP > day open / prev close).
  bool get isGain => change > Decimal.zero;

  /// Net loss for the session (LTP < day open / prev close).
  bool get isLoss => change < Decimal.zero;

  /// Neutral / unchanged for the session.
  bool get isFlat => change == Decimal.zero;

  /// Micro-tick moved up from immediate previous price.
  bool get isTickUp => direction == TickDirection.up;

  /// Micro-tick moved down from immediate previous price.
  bool get isTickDown => direction == TickDirection.down;

  @override
  List<Object?> get props =>
      [symbol, ltp, change, changePercent, timestamp, direction];
}
