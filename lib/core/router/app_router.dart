import 'package:go_router/go_router.dart';
import '../../presentation/pages/shell/main_shell_page.dart';
import '../../presentation/pages/market/live_prices_page.dart';
import '../../presentation/pages/watchlist/watchlist_page.dart';
import '../../presentation/pages/holdings/holdings_page.dart';
import '../../presentation/pages/order/order_ticket_page.dart';
import '../../presentation/pages/order/order_confirmation_page.dart';
import '../../domain/entities/order.dart';

/// Route names — never hardcode path strings outside this file.
class AppRoutes {
  AppRoutes._();
  static const market = '/market';
  static const watchlists = '/watchlists';
  static const holdings = '/holdings';
  static const order = '/order';
  static const orderConfirmation = '/order-confirmation';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.market,
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShellPage(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.market,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: LivePricesPage()),
        ),
        GoRoute(
          path: AppRoutes.watchlists,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: WatchlistPage()),
        ),
        GoRoute(
          path: AppRoutes.holdings,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HoldingsPage()),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.order,
      builder: (context, state) {
        final symbol = state.uri.queryParameters['symbol'] ?? '';
        final side = state.uri.queryParameters['side'] ?? 'buy';
        return OrderTicketPage(symbol: symbol, initialSide: side);
      },
    ),
    GoRoute(
      path: AppRoutes.orderConfirmation,
      builder: (context, state) {
        final order = state.extra as Order;
        return OrderConfirmationPage(order: order);
      },
    ),
  ],
);
