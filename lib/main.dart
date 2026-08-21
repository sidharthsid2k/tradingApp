import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'data/datasources/local/app_database.dart';
import 'data/datasources/mock/mock_market_feed.dart';
import 'data/repositories/watchlist_repository_impl.dart';
import 'data/repositories/holdings_repository_impl.dart';
import 'data/repositories/order_repository_impl.dart';
import 'data/repositories/wallet_repository_impl.dart';
import 'domain/repositories/i_watchlist_repository.dart';
import 'domain/repositories/i_holdings_repository.dart';
import 'domain/repositories/i_order_repository.dart';
import 'domain/repositories/i_wallet_repository.dart';
import 'domain/usecases/watchlist/get_watchlists_usecase.dart';
import 'domain/usecases/watchlist/create_watchlist_usecase.dart';
import 'domain/usecases/watchlist/rename_watchlist_usecase.dart';
import 'domain/usecases/watchlist/delete_watchlist_usecase.dart';
import 'domain/usecases/watchlist/add_stock_to_watchlist_usecase.dart';
import 'domain/usecases/watchlist/remove_stock_from_watchlist_usecase.dart';
import 'domain/usecases/watchlist/reorder_stock_usecase.dart';
import 'domain/usecases/holdings/get_holdings_usecase.dart';
import 'presentation/providers/market_viewmodel.dart';
import 'presentation/providers/watchlist_viewmodel.dart';
import 'presentation/providers/holdings_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for phone-first layout
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // ── Infrastructure ──────────────────────────────────────────────────────────
  final db = AppDatabase();
  final feed = MockMarketFeed();

  // ── Repositories ─────────────────────────────────────────────────────────────
  final watchlistRepo = WatchlistRepositoryImpl(db);
  final holdingsRepo = HoldingsRepositoryImpl(db);
  final orderRepo = OrderRepositoryImpl(db);
  final walletRepo = WalletRepositoryImpl(db);

  runApp(
    MultiProvider(
      providers: [
        // ── Infrastructure ─────────────────────────────────────────────────────
        Provider<AppDatabase>.value(value: db),
        Provider<MockMarketFeed>.value(value: feed),

        // ── Repositories ────────────────────────────────────────────────────────
        Provider<IWatchlistRepository>.value(value: watchlistRepo),
        Provider<IHoldingsRepository>.value(value: holdingsRepo),
        Provider<IOrderRepository>.value(value: orderRepo),
        Provider<IWalletRepository>.value(value: walletRepo),

        // ── ViewModels ──────────────────────────────────────────────────────────
        ChangeNotifierProvider<MarketViewModel>(
          create: (_) => MarketViewModel(feed),
        ),

        ChangeNotifierProvider<WatchlistViewModel>(
          create: (ctx) => WatchlistViewModel(
            getWatchlists: GetWatchlistsUseCase(watchlistRepo),
            createWatchlist: CreateWatchlistUseCase(watchlistRepo),
            renameWatchlist: RenameWatchlistUseCase(watchlistRepo),
            deleteWatchlist: DeleteWatchlistUseCase(watchlistRepo),
            addStock: AddStockToWatchlistUseCase(watchlistRepo),
            removeStock: RemoveStockFromWatchlistUseCase(watchlistRepo),
            reorderStock: ReorderStockUseCase(watchlistRepo),
          ),
        ),

        ChangeNotifierProvider<HoldingsViewModel>(
          create: (_) => HoldingsViewModel(GetHoldingsUseCase(holdingsRepo)),
        ),
      ],
      child: const TradingApp(),
    ),
  );
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
