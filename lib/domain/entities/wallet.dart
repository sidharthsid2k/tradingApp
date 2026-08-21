import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

/// The user's cash wallet / margin account.
class Wallet extends Equatable {
  const Wallet({
    required this.balance,
    required this.totalInvested,
  });

  /// Available cash balance.
  final Decimal balance;

  /// Cumulative amount invested (sum of all buy order values, net of sells).
  final Decimal totalInvested;

  Wallet copyWith({Decimal? balance, Decimal? totalInvested}) => Wallet(
        balance: balance ?? this.balance,
        totalInvested: totalInvested ?? this.totalInvested,
      );

  @override
  List<Object?> get props => [balance, totalInvested];
}
