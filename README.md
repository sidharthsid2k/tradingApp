# StockPro - Real-Time Trading App

A high-performance, real-time Flutter trading application built with **Clean Architecture**, **Drift SQLite persistence**, **`package:decimal` money handling**, and responsive UI in a modern, accessible **Light Theme**.

---

## 📱 Features

### 1. 📊 Live Market Feed (Market Mimic)
- Real-time continuous market feed for 10 premier NSE stocks: `RELIANCE`, `TCS`, `INFY`, `HDFCBANK`, `ICICIBANK`, `SBIN`, `ITC`, `LT`, `BHARTIARTL`, and `AXISBANK`.
- Synchronizes with **live market quotes** over HTTPS and simulates micro-tick market movements.
- Top-level overview cards tracking count of Gainers, Losers, and Total Active Tickers.
- High-efficiency rendering using granular `Selector` patterns that eliminates unnecessary widget rebuilds even under 50+ ticks/sec stress load.

### 2. ⭐ Multi-Watchlist Management & Search
- **Full CRUD**: Create, rename, and delete multiple custom watchlists with persistence across app restarts.
- **Real-Time Stock Search**: Search bar in the stock picker sheet and directly above watchlist items to filter stocks by **symbol** (e.g. `TCS`, `INFY`) or **company name** (e.g. `Tata`, `Infosys`).
- **Drag-and-Drop Reordering**: Built with `ReorderableListView` backed by atomic SQLite transaction reordering.
- **Direct Order Navigation**: Tapping any stock row opens the pre-filled Buy/Sell order ticket.

### 3. 💳 Buy / Sell Order Ticket
- **Market & Limit Orders**:
  - Seamlessly toggle between **`Price Limit ↕`** and **`Price Market ↕`**.
  - **Limit Order**: Enter any target price with decimal formatting and real-time order value calculation.
  - **Market Order**: Instantly executes at the real-time LTP.
- **Existing Position / Holding Card**:
  - When viewing a stock you already own, an inline card displays **Shares owned**, **Average purchase price**, **Current holding value**, and **Live P&L** (`₹` and `%`).
- **Dynamic Projected Value**: Calculated as `Quantity × Price` with automatic font auto-scaling (`FittedBox` / `Expanded`) to handle large numbers without overflow.
- **Strict Validations & Contextual Warning Banners**:
  - Available wallet balance / margin check with clean inline warnings (e.g., *"Available amount is not enough"*).
  - Quantity-held check for Sell orders (*"Not enough shares to sell"*).
  - Clean input handling with disabled submission until valid values are supplied.
- **Atomic SQLite Execution**: Deducts from wallet or holdings atomically, records the order, and navigates to the animated confirmation screen.

### 4. 💼 Holdings & Portfolio Tracker
- Real-time portfolio tracking:
  - **Summary Card**: Total Invested, Current Value, and Total P&L (₹ and %).
  - **Individual Holdings**: Symbol, Quantity, Weighted Average Cost, LTP, Current Value, and P&L (₹ and %).
- Dynamic sorting by **P&L** (default), **Symbol**, or **Current Value**.
- Automatic weighted average price calculation on subsequent buy orders and complete removal when sold to zero.
- Tapping any holding row opens the pre-filled order ticket.

---

## 🏛️ Clean Architecture & Project Structure

The project strictly follows Clean Architecture principles:

```
lib/
├── core/                         # Cross-cutting concerns & foundational elements
│   ├── constants/                # AppColors, AppTextStyles, AppStrings, StockConstants
│   ├── extensions/               # DecimalExt (Indian INR numbering format, WAC math)
│   ├── errors/                   # AppException hierarchy
│   ├── router/                   # GoRouter navigation & ShellRoute configuration
│   └── theme/                    # AppTheme (Light mode design system)
├── domain/                       # Core business layer (Pure Dart, zero external dependencies)
│   ├── entities/                 # Stock, PriceTick, Watchlist, Holding, Order, Wallet
│   ├── repositories/             # Repository interfaces (IWatchlistRepository, etc.)
│   └── usecases/                 # Single-responsibility use-cases (Buy, Sell, Reorder, etc.)
├── data/                         # Data access layer
│   ├── datasources/
│   │   ├── local/                # Drift SQLite database, tables, and DAOs
│   │   └── mock/                 # MockMarketFeed (live quotes & tick stream)
│   └── repositories/             # Implementations of domain repository interfaces
└── presentation/                 # Presentation layer (MVVM)
    ├── dialogs/                  # StockPickerSheet (with Search), WatchlistNameDialog
    ├── pages/
    │   ├── market/               # LivePricesPage
    │   ├── watchlist/            # WatchlistPage (Multi-tab with reordering)
    │   ├── holdings/             # HoldingsPage (Portfolio summary & holdings list)
    │   ├── order/                # OrderTicketPage & OrderConfirmationPage
    │   └── shell/                # MainShellPage (Bottom navigation)
    ├── providers/                # MarketViewModel, WatchlistViewModel, HoldingsViewModel, OrderViewModel
    └── widgets/                  # StockTickerRow, HoldingRow, EmptyStateWidget
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
cd tradingapp

# 2. Get dependencies
flutter pub get

# 3. Run the application
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
