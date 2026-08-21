import 'package:flutter/foundation.dart';
import '../../domain/entities/watchlist.dart';
import '../../domain/usecases/watchlist/get_watchlists_usecase.dart';
import '../../domain/usecases/watchlist/create_watchlist_usecase.dart';
import '../../domain/usecases/watchlist/rename_watchlist_usecase.dart';
import '../../domain/usecases/watchlist/delete_watchlist_usecase.dart';
import '../../domain/usecases/watchlist/add_stock_to_watchlist_usecase.dart';
import '../../domain/usecases/watchlist/remove_stock_from_watchlist_usecase.dart';
import '../../domain/usecases/watchlist/reorder_stock_usecase.dart';

/// ViewModel for the Watchlist feature.
///
/// Manages multiple watchlists. Persists changes via use-cases.
/// The UI subscribes via [ChangeNotifier] / [Selector].
class WatchlistViewModel extends ChangeNotifier {
  WatchlistViewModel({
    required GetWatchlistsUseCase getWatchlists,
    required CreateWatchlistUseCase createWatchlist,
    required RenameWatchlistUseCase renameWatchlist,
    required DeleteWatchlistUseCase deleteWatchlist,
    required AddStockToWatchlistUseCase addStock,
    required RemoveStockFromWatchlistUseCase removeStock,
    required ReorderStockUseCase reorderStock,
  })  : _getWatchlists = getWatchlists,
        _createWatchlist = createWatchlist,
        _renameWatchlist = renameWatchlist,
        _deleteWatchlist = deleteWatchlist,
        _addStock = addStock,
        _removeStock = removeStock,
        _reorderStock = reorderStock {
    loadAll();
  }

  final GetWatchlistsUseCase _getWatchlists;
  final CreateWatchlistUseCase _createWatchlist;
  final RenameWatchlistUseCase _renameWatchlist;
  final DeleteWatchlistUseCase _deleteWatchlist;
  final AddStockToWatchlistUseCase _addStock;
  final RemoveStockFromWatchlistUseCase _removeStock;
  final ReorderStockUseCase _reorderStock;

  List<Watchlist> _watchlists = [];
  bool _isLoading = false;
  String? _error;

  List<Watchlist> get watchlists => List.unmodifiable(_watchlists);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _watchlists.isEmpty;

  // ─── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _watchlists = await _getWatchlists();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── CRUD ─────────────────────────────────────────────────────────────────

  Future<void> createWatchlist(String name) async {
    try {
      final created = await _createWatchlist(name);
      _watchlists = [..._watchlists, created];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> renameWatchlist(String id, String newName) async {
    await _renameWatchlist(id, newName);
    _watchlists = _watchlists.map((w) {
      return w.id == id ? w.copyWith(name: newName) : w;
    }).toList();
    notifyListeners();
  }

  Future<void> deleteWatchlist(String id) async {
    await _deleteWatchlist(id);
    _watchlists = _watchlists.where((w) => w.id != id).toList();
    notifyListeners();
  }

  // ─── Stocks within a watchlist ────────────────────────────────────────────

  Future<void> addStock(String watchlistId, String symbol) async {
    await _addStock(watchlistId, symbol);
    _watchlists = _watchlists.map((w) {
      if (w.id != watchlistId) return w;
      if (w.symbolOrder.contains(symbol)) return w;
      return w.copyWith(symbolOrder: [...w.symbolOrder, symbol]);
    }).toList();
    notifyListeners();
  }

  Future<void> removeStock(String watchlistId, String symbol) async {
    await _removeStock(watchlistId, symbol);
    _watchlists = _watchlists.map((w) {
      if (w.id != watchlistId) return w;
      return w.copyWith(
          symbolOrder: w.symbolOrder.where((s) => s != symbol).toList());
    }).toList();
    notifyListeners();
  }

  Future<void> reorderStock(
      String watchlistId, int oldIndex, int newIndex) async {
    // Optimistic update so UI feels instant
    _watchlists = _watchlists.map((w) {
      if (w.id != watchlistId) return w;
      final symbols = List<String>.from(w.symbolOrder);
      final symbol = symbols.removeAt(oldIndex);
      symbols.insert(newIndex, symbol);
      return w.copyWith(symbolOrder: symbols);
    }).toList();
    notifyListeners();

    // Persist in background
    await _reorderStock(watchlistId, oldIndex, newIndex);
  }

  Watchlist? watchlistById(String id) {
    try {
      return _watchlists.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }
}
