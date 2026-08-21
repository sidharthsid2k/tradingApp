import 'package:equatable/equatable.dart';

/// An ordered collection of stock symbols tracked by the user.
class Watchlist extends Equatable {
  const Watchlist({
    required this.id,
    required this.name,
    required this.symbolOrder,
    required this.sortOrder,
  });

  final String id;
  final String name;

  /// Symbols in the user-defined display order.
  final List<String> symbolOrder;

  /// Position of this watchlist in the tab bar.
  final int sortOrder;

  Watchlist copyWith({
    String? name,
    List<String>? symbolOrder,
    int? sortOrder,
  }) =>
      Watchlist(
        id: id,
        name: name ?? this.name,
        symbolOrder: symbolOrder ?? this.symbolOrder,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  @override
  List<Object?> get props => [id, name, symbolOrder, sortOrder];
}
