# StockPro - Real-Time Trading App

A high-performance, real-time Flutter trading application built with **Clean Architecture**, **Drift SQLite persistence**, **ACID Database Transactions**, **`package:decimal` money handling**, and a responsive UI in a modern **Light Theme**.

---

## 📱 Features

### 1. 📊 Live Market Feed (Market Mimic)
- Real-time continuous market feed for 10 premier NSE stocks: `RELIANCE`, `TCS`, `INFY`, `HDFCBANK`, `ICICIBANK`, `SBIN`, `ITC`, `LT`, `BHARTIARTL`, and `AXISBANK`.
- Synchronizes with **live market quotes** over HTTPS and simulates micro-tick market movements every second using Gaussian volatility (Box-Muller transform) bounded by circuit limits.
- Top-level overview cards tracking count of Gainers, Losers, and Total Active Tickers.
- High-efficiency rendering using granular `Selector` patterns that eliminates unnecessary widget rebuilds even under 50+ ticks/sec stress load.
- **24/7 Simulation Mode**: Allows continuous price ticking and order testing even outside official NSE market hours.

### 2. ⭐ Multi-Watchlist Management & Search
- **Full CRUD**: Create, rename, and delete multiple custom watchlists with persistence across app restarts.
- **Real-Time Stock Search**: Search bar in the stock picker sheet and directly above watchlist items to filter stocks by **symbol** (e.g. `TCS`, `INFY`) or **company name** (e.g. `Tata`, `Infosys`).
- **Drag-and-Drop Reordering**: Built with `ReorderableListView` backed by atomic SQLite transaction reordering.
- **Direct Order Navigation**: Tapping any stock row opens the pre-filled Buy/Sell order ticket.

### 3. 💳 Buy / Sell Order Ticket
- **Market & Limit Orders**:
  - Seamlessly toggle between **`Price Limit ↕`** and **`Price Market ↕`**.
  - **Market Order**: Instantly executes at the real-time market LTP.
  - **Limit Order**: Enter a target price. If the price does not match current LTP (e.g. BUY @ ₹750 when market is ₹738), the order safely enters **`PENDING (Open)`** status without prematurely deducting cash or creating phantom holdings.
- **Existing Position / Holding Card**:
  - When viewing a stock you already own, an inline card displays **Shares owned**, **Average purchase price**, **Current holding value**, and **Live P&L** (`₹` and `%`).
- **Dynamic Projected Value**: Calculated as `Quantity × Price` with automatic font auto-scaling (`FittedBox` / `Expanded`) to handle large numbers without overflow.
- **Strict Validations & Contextual Warning Banners**:
  - Available wallet balance check with inline warnings (*"Available amount is not enough"*).
  - Quantity-held check for Sell orders (*"Not enough shares to sell"*).
  - Clean input handling with disabled submission until valid values are supplied.

### 4. 📑 Dedicated Orders Book & Real-Time Matching Engine
- **Tabbed Order Management**:
  - **Open (Pending)**: Displays all active limit orders awaiting price execution. Shows target Limit Price, live LTP, trigger rule, and a **Cancel Order** button.
  - **Executed**: Shows all completed trades with executed price, total value, and execution timestamp.
- **Active Orders Badge**: Bottom navigation bar displays an active count badge whenever there are pending orders.
- **Tick-Driven Matching Engine**: `OrdersViewModel` subscribes to real-time `MockMarketFeed` price ticks. When a stock's market LTP reaches the target limit price, it **automatically executes the order**, updates portfolio holdings, deducts/credits the wallet, and moves the order to `Executed`.

### 5. 💼 Holdings & Portfolio Tracker
- **Real-Time Portfolio Tracking**:
  - **Summary Card**: Total Invested, Current Value, and Total P&L (₹ and %).
  - **Individual Holdings**: Symbol, Quantity, Weighted Average Cost, LTP, Current Value, and P&L (₹ and %).
- **Interactive Portfolio Actions**:
  - **Tap Action Sheet**: Tap any holding to view stock details with quick **BUY MORE**, **SELL**, and **Remove from Portfolio** options.
  - **Swipe to Delete**: Swipe left on any holding row to remove it with automatic invested fund refund to your wallet.
  - **Clear All Holdings**: Overflow menu (`⋮`) option to clear all test holdings and restore full wallet cash.
- Dynamic sorting by **P&L** (default), **Symbol**, or **Current Value**.
- Automatic weighted average price calculation on subsequent buy orders and complete removal when sold to zero.

### 6. 🔒 ACID Database Transactions & Rollback Protection
- **No Partial Fails**: Replaced uncoordinated `Future.wait` persistence with native SQLite transactions via `ITransactionRunner`.
- **Automatic Rollback**: If an order insertion, holding update, or wallet operation encounters an error, SQLite automatically issues a **`ROLLBACK`**, ensuring zero state corruption or lost funds.

---

## 🏛️ Clean Architecture & Project Structure

The project strictly follows Clean Architecture principles:

```
lib/
├── core/                         # Cross-cutting concerns & foundational elements
│   ├── constants/                # AppColors, AppTextStyles, AppStrings, StockConstants
│   ├── extensions/               # DecimalExt (Indian INR numbering format, WAC math)
│   ├── errors/                   # AppException hierarchy (StorageException, BusinessException)
│   ├── router/                   # GoRouter navigation & ShellRoute configuration (/market, /watchlists, /orders, /holdings)
│   └── theme/                    # AppTheme (Light mode design system)
├── domain/                       # Core business layer (Pure Dart, zero external dependencies)
│   ├── entities/                 # Stock, PriceTick, Watchlist, Holding, Order (Status, Type, Trigger), Wallet
│   ├── repositories/             # Repository interfaces (IWatchlistRepository, IOrderRepository, ITransactionRunner, etc.)
│   └── usecases/                 # Single-responsibility use-cases:
│       ├── order/                # PlaceBuyOrderUseCase, PlaceSellOrderUseCase, ExecuteOrderUseCase, CancelOrderUseCase
│       ├── holdings/             # GetHoldingsUseCase, DeleteHoldingUseCase
│       └── watchlist/            # Watchlist CRUD & reorder use-cases
├── data/                         # Data access layer
│   ├── datasources/
│   │   ├── local/                # Drift SQLite database, tables (Orders, Holdings, Wallet, Watchlists), and DAOs
│   │   └── mock/                 # MockMarketFeed (live quotes & tick stream)
│   └── repositories/             # Repository implementations (OrderRepositoryImpl, TransactionRunnerImpl, etc.)
└── presentation/                 # Presentation layer (MVVM)
    ├── dialogs/                  # StockPickerSheet (with Search), WatchlistNameDialog
    ├── pages/
    │   ├── market/               # LivePricesPage
    │   ├── watchlist/            # WatchlistPage (Multi-tab with reordering)
    │   ├── orders/               # OrdersPage (Open & Executed tabs)
    │   ├── holdings/             # HoldingsPage (Portfolio summary, swipe delete, actions)
    │   ├── order/                # OrderTicketPage & OrderConfirmationPage
    │   └── shell/                # MainShellPage (4-tab bottom navigation with badge)
    ├── providers/                # MarketViewModel, WatchlistViewModel, HoldingsViewModel, OrderViewModel, OrdersViewModel
    └── widgets/                  # StockTickerRow, HoldingRow, OrderCard, EmptyStateWidget
```

---

## 💰 Precision Money & Indian Currency Numbering

To prevent binary floating-point drift (e.g. `0.1 + 0.2 != 0.3`):
- All financial balances, prices, quantities, and order values use **`Decimal`** from `package:decimal`.
- Stored as precise strings in SQLite tables.
- Formatted in standard **Indian Numbering System** (`₹89,20,53,67,089.00` and `₹6,09,560.00`) via [`DecimalExt`](lib/core/extensions/decimal_ext.dart).
- Weighted average price uses exact rational arithmetic:
  $$\text{New Avg Cost} = \frac{(\text{Prev Qty} \times \text{Prev Avg}) + (\text{New Qty} \times \text{Execution Price})}{\text{Prev Qty} + \text{New Qty}}$$

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Channel `stable`)
- Android Studio / VS Code / Xcode (for iOS) or an active simulator/emulator

### Running the App

```bash
# 1. Clone the repository
git clone https://github.com/sidharthsid2k/tradingApp.git
cd tradingApp

# 2. Get dependencies
flutter pub get

# 3. (Optional) Regenerate Drift database code
dart run build_runner build --delete-conflicting-outputs

# 4. Run the application
flutter run
```

### Static Analysis

```bash
dart analyze
```

---

## 📈 Supported Stocks

| Symbol | Company | Sector |
| :--- | :--- | :--- |
| **RELIANCE** | Reliance Industries Ltd | Energy / Conglomerate |
| **TCS** | Tata Consultancy Services | Technology |
| **INFY** | Infosys Ltd | Technology |
| **HDFCBANK** | HDFC Bank Ltd | Banking |
| **ICICIBANK** | ICICI Bank Ltd | Banking |
| **SBIN** | State Bank of India | Banking |
| **ITC** | ITC Limited | FMCG |
| **LT** | Larsen & Toubro | Infrastructure |
| **BHARTIARTL** | Bharti Airtel | Telecom |
| **AXISBANK** | Axis Bank Ltd | Banking |
