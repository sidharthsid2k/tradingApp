/// All user-facing strings in one place — no static strings elsewhere.
class AppStrings {
  AppStrings._();

  // ─── App ────────────────────────────────────────────────────────────────────
  static const appName = 'StockPro';
  static const appTagline = 'Smart Trading, Real Insights';

  // ─── Bottom Nav ─────────────────────────────────────────────────────────────
  static const navMarket = 'Market';
  static const navWatchlists = 'Watchlists';
  static const navOrders = 'Orders';
  static const navHoldings = 'Holdings';

  // ─── Live Prices ─────────────────────────────────────────────────────────────
  static const livePricesTitle = 'Live Market';
  static const livePricesSubtitle = 'NSE · Real-time';
  static const allStocks = 'All Stocks';

  // ─── Watchlist ───────────────────────────────────────────────────────────────
  static const watchlistsTitle = 'Watchlists';
  static const newWatchlist = 'New Watchlist';
  static const addWatchlist = 'Add Watchlist';
  static const watchlistNameLabel = 'Watchlist Name';
  static const watchlistNameHint = 'e.g. Tech Picks';
  static const renameWatchlist = 'Rename Watchlist';
  static const deleteWatchlist = 'Delete Watchlist';
  static const deleteWatchlistConfirm =
      'Are you sure you want to delete this watchlist?';
  static const addStocks = 'Add Stocks';
  static const emptyWatchlistTitle = 'No Stocks Added';
  static const emptyWatchlistSubtitle =
      'Tap + to add stocks to this watchlist';
  static const emptyWatchlistsTitle = 'No Watchlists Yet';
  static const emptyWatchlistsSubtitle =
      'Tap + to create your first watchlist';
  static const alreadyAdded = 'Added';
  static const tapToAdd = 'Tap to add';
  static const searchStocksHint = 'Search stocks by name or symbol...';
  static const noStocksFound = 'No stocks found';
  static const noStocksFoundSubtitle = 'Try searching with a different symbol or name';
  static const addStock = 'Add';
  static const addedToWatchlist = 'Added to watchlist';

  // ─── Holdings ────────────────────────────────────────────────────────────────
  static const holdingsTitle = 'Holdings';
  static const totalInvested = 'Invested';
  static const currentValueLabel = 'Current Value';
  static const totalPnlLabel = 'Total P&L';
  static const sortBy = 'Sort by';
  static const sortByPnl = 'P&L';
  static const sortBySymbol = 'Symbol';
  static const sortByValue = 'Value';
  static const emptyHoldingsTitle = 'No Holdings Yet';
  static const emptyHoldingsSubtitle =
      'Place a buy order to start building your portfolio';
  static const avgCost = 'Avg Cost';
  static const avgPrice = 'Avg Price';
  static const qtyLabel = 'Qty';
  static const ltpLabel = 'LTP';

  // ─── Order Ticket ────────────────────────────────────────────────────────────
  static const orderTicketTitle = 'Place Order';
  static const buy = 'BUY';
  static const sell = 'SELL';
  static const orderQtyLabel = 'Quantity';
  static const orderQtyHint = '0';
  static const priceLimitLabel = 'Price Limit';
  static const priceMarketLabel = 'Price Market';
  static const market = 'Market';
  static const limit = 'Limit';
  static const atMarket = 'At Market';
  static const orderType = 'Order Type';
  static const availableBalance = 'Available Balance';
  static const qtyHeld = 'Qty Held';
  static const orderValueLabel = 'Order Value';
  static const placeOrder = 'Place Order';
  static const submitting = 'Processing…';

  // ─── Orders ──────────────────────────────────────────────────────────────────
  static const ordersTitle = 'Orders';
  static const tabOpenOrders = 'Open';
  static const tabExecutedOrders = 'Executed';
  static const emptyOpenOrdersTitle = 'No Open Orders';
  static const emptyOpenOrdersSubtitle =
      'Your pending limit orders will appear here until triggered';
  static const emptyExecutedOrdersTitle = 'No Executed Orders';
  static const emptyExecutedOrdersSubtitle =
      'Completed buy and sell orders will appear here';
  static const viewOrders = 'View Orders';
  static const orderPending = 'Order Submitted!';
  static const orderPendingSubtitle =
      'Will execute automatically when price reaches';
  static const statusPending = 'OPEN';
  static const statusExecuted = 'EXECUTED';
  static const statusCancelled = 'CANCELLED';
  static const cancelOrder = 'Cancel Order';
  static const cancelOrderConfirm =
      'Are you sure you want to cancel this pending order?';
  static const orderCancelled = 'Order Cancelled';
  static const limitPrice = 'Limit Price';
  static const triggerAt = 'Trigger';

  // ─── Order Confirmation ──────────────────────────────────────────────────────
  static const orderSuccess = 'Order Placed!';
  static const orderConfirmationTitle = 'Order Confirmed';
  static const viewHoldings = 'View Holdings';
  static const placeAnother = 'Place Another Order';
  static const doneLabel = 'Done';
  static const executedAt = 'Executed at';
  static const orderId = 'Order ID';
  static const orderTime = 'Time';

  // ─── Validation ──────────────────────────────────────────────────────────────
  static const errInvalidQty = 'Enter a valid quantity';
  static const errQtyPositive = 'Quantity must be greater than 0';
  static const errInvalidPrice = 'Price must be greater than 0';
  static const errInsufficientBalance = 'Available amount is not enough';
  static const errInsufficientQty = 'Not enough shares to sell';
  static const errNoHoldings = 'You don\'t hold any shares of this stock';

  // ─── General ─────────────────────────────────────────────────────────────────
  static const cancel = 'Cancel';
  static const create = 'Create';
  static const rename = 'Rename';
  static const delete = 'Delete';
  static const confirm = 'Confirm';
  static const currencySymbol = '₹';
  static const change = 'Change';
  static const changePct = 'Chg%';
  static const symbolLabel = 'Symbol';
  static const priceLabel = 'Price';
  static const valueLabel = 'Value';
  static const pnlLabel = 'P&L';
  static const upArrow = '▲';
  static const downArrow = '▼';
  static const flatDash = '–';

  // ─── Debug ───────────────────────────────────────────────────────────────────
  static const debugSettings = 'Debug Settings';
  static const tickRateLabel = 'Tick Interval';
  static const tickRateUnit = 'ms';
}
