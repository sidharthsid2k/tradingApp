import 'package:flutter_test/flutter_test.dart';
import 'package:decimal/decimal.dart';
import 'package:tradingapp/domain/entities/order.dart';
import 'package:tradingapp/domain/entities/wallet.dart';
import 'package:tradingapp/domain/entities/holding.dart';
import 'package:tradingapp/domain/repositories/i_wallet_repository.dart';
import 'package:tradingapp/domain/repositories/i_holdings_repository.dart';
import 'package:tradingapp/domain/repositories/i_order_repository.dart';
import 'package:tradingapp/domain/repositories/i_transaction_runner.dart';
import 'package:tradingapp/domain/usecases/order/place_buy_order_usecase.dart';
import 'package:tradingapp/domain/usecases/order/execute_order_usecase.dart';
import 'package:tradingapp/domain/usecases/order/cancel_order_usecase.dart';
import 'package:tradingapp/core/errors/app_exception.dart';

class FakeTransactionRunner implements ITransactionRunner {
  final FakeWalletRepository walletRepo;
  final FakeHoldingsRepository holdingsRepo;

  FakeTransactionRunner({
    required this.walletRepo,
    required this.holdingsRepo,
  });

  @override
  Future<T> run<T>(Future<T> Function() action) async {
    // Snapshot state for rollback simulation
    final walletSnapshot = walletRepo.wallet.copyWith();
    final holdingsSnapshot = Map<String, Holding>.from(holdingsRepo.holdingsMap);

    try {
      return await action();
    } catch (_) {
      // Rollback on failure
      walletRepo.wallet = walletSnapshot;
      holdingsRepo.holdingsMap
        ..clear()
        ..addAll(holdingsSnapshot);
      rethrow;
    }
  }
}

class FakeWalletRepository implements IWalletRepository {
  Wallet wallet = Wallet(
    balance: Decimal.parse('100000.00'),
    totalInvested: Decimal.zero,
  );

  @override
  Future<Wallet> get() async => wallet;

  @override
  Future<void> save(Wallet newWallet) async {
    wallet = newWallet;
  }
}

class FakeHoldingsRepository implements IHoldingsRepository {
  final Map<String, Holding> holdingsMap = {};

  @override
  Future<List<Holding>> getAll() async => holdingsMap.values.toList();

  @override
  Future<Holding?> getBySymbol(String symbol) async => holdingsMap[symbol];

  @override
  Future<void> upsert(Holding holding) async {
    holdingsMap[holding.symbol] = holding;
  }

  @override
  Future<void> delete(String symbol) async {
    holdingsMap.remove(symbol);
  }
}

class FakeOrderRepository implements IOrderRepository {
  final List<Order> _orders = [];
  bool simulateInsertFailure = false;

  @override
  Future<List<Order>> getAll() async => List.unmodifiable(_orders);

  @override
  Future<List<Order>> getPending() async =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();

  @override
  Future<List<Order>> getExecuted() async =>
      _orders.where((o) => o.status == OrderStatus.executed).toList();

  @override
  Future<Order?> getById(String id) async {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> insert(Order order) async {
    if (simulateInsertFailure) {
      throw Exception('Simulated SQLite disk write failure');
    }
    _orders.add(order);
  }

  @override
  Future<void> update(Order order) async {
    final idx = _orders.indexWhere((o) => o.id == order.id);
    if (idx != -1) {
      _orders[idx] = order;
    }
  }

  @override
  Future<void> delete(String id) async {
    _orders.removeWhere((o) => o.id == id);
  }
}

void main() {
  group('Limit Order Matching & Lifecycle', () {
    late FakeWalletRepository walletRepo;
    late FakeHoldingsRepository holdingsRepo;
    late FakeOrderRepository orderRepo;
    late FakeTransactionRunner transactionRunner;
    late PlaceBuyOrderUseCase placeBuyOrder;
    late ExecuteOrderUseCase executeOrder;
    late CancelOrderUseCase cancelOrder;

    setUp(() {
      walletRepo = FakeWalletRepository();
      holdingsRepo = FakeHoldingsRepository();
      orderRepo = FakeOrderRepository();
      transactionRunner = FakeTransactionRunner(
        walletRepo: walletRepo,
        holdingsRepo: holdingsRepo,
      );

      placeBuyOrder = PlaceBuyOrderUseCase(
        walletRepo: walletRepo,
        holdingsRepo: holdingsRepo,
        orderRepo: orderRepo,
        transactionRunner: transactionRunner,
      );
      executeOrder = ExecuteOrderUseCase(
        walletRepo: walletRepo,
        holdingsRepo: holdingsRepo,
        orderRepo: orderRepo,
        transactionRunner: transactionRunner,
      );
      cancelOrder = CancelOrderUseCase(orderRepo);
    });

    test(
        'Buying at ₹750 when current price is ₹738 creates a PENDING order without immediate execution',
        () async {
      final initialBalance = (await walletRepo.get()).balance;

      final order = await placeBuyOrder(
        symbol: 'HDFCBANK',
        quantity: 20,
        price: Decimal.parse('750.00'),
        orderType: OrderType.limit,
        currentLtp: Decimal.parse('738.01'),
      );

      // Order should be PENDING and queued in Orders
      expect(order.status, OrderStatus.pending);
      expect(order.isPending, isTrue);
      expect(order.limitPrice, Decimal.parse('750.00'));
      expect(order.executedPrice, isNull);
      expect(order.triggerDirection, TriggerDirection.gte);

      // Wallet should NOT be deducted yet
      final walletAfter = await walletRepo.get();
      expect(walletAfter.balance, initialBalance);
      expect(walletAfter.totalInvested, Decimal.zero);

      // Holdings should NOT have HDFCBANK yet
      final holding = await holdingsRepo.getBySymbol('HDFCBANK');
      expect(holding, isNull);

      // Order should be in repository under pending
      final pendingOrders = await orderRepo.getPending();
      expect(pendingOrders.length, 1);
      expect(pendingOrders.first.id, order.id);
    });

    test(
        'When market price reaches ₹750.00, pending order executes automatically and updates holding/wallet',
        () async {
      // 1. Place limit order at 750 when price is 738
      final order = await placeBuyOrder(
        symbol: 'HDFCBANK',
        quantity: 20,
        price: Decimal.parse('750.00'),
        orderType: OrderType.limit,
        currentLtp: Decimal.parse('738.01'),
      );

      // 2. Trigger executes when market reaches ₹750.00
      final executed = await executeOrder(
        order: order,
        executionPrice: Decimal.parse('750.00'),
      );

      expect(executed.status, OrderStatus.executed);
      expect(executed.executedPrice, Decimal.parse('750.00'));
      expect(executed.totalValue, Decimal.parse('15000.00'));

      // 3. Verify holding is now created
      final holding = await holdingsRepo.getBySymbol('HDFCBANK');
      expect(holding, isNotNull);
      expect(holding!.quantity, 20);
      expect(holding.avgCost, Decimal.parse('750.00'));

      // 4. Verify wallet balance deducted
      final wallet = await walletRepo.get();
      expect(wallet.balance, Decimal.parse('85000.00'));
      expect(wallet.totalInvested, Decimal.parse('15000.00'));

      // 5. Verify order is now under executed
      final pending = await orderRepo.getPending();
      final done = await orderRepo.getExecuted();
      expect(pending.isEmpty, isTrue);
      expect(done.length, 1);
      expect(done.first.id, order.id);
    });

    test('Pending limit order can be cancelled', () async {
      final order = await placeBuyOrder(
        symbol: 'HDFCBANK',
        quantity: 20,
        price: Decimal.parse('750.00'),
        orderType: OrderType.limit,
        currentLtp: Decimal.parse('738.01'),
      );

      final cancelled = await cancelOrder(order);
      expect(cancelled.status, OrderStatus.cancelled);
      expect(cancelled.isCancelled, isTrue);

      final pending = await orderRepo.getPending();
      expect(pending.isEmpty, isTrue);
    });

    test('Market order executes immediately at current LTP', () async {
      final order = await placeBuyOrder(
        symbol: 'TCS',
        quantity: 5,
        price: Decimal.parse('3800.00'),
        orderType: OrderType.market,
        currentLtp: Decimal.parse('3800.00'),
      );

      expect(order.status, OrderStatus.executed);
      expect(order.executedPrice, Decimal.parse('3800.00'));

      final holding = await holdingsRepo.getBySymbol('TCS');
      expect(holding?.quantity, 5);
    });

    test(
        'Transaction rollback: when orderRepo.insert fails, wallet and holdings are rolled back and StorageException is thrown',
        () async {
      final initialBalance = (await walletRepo.get()).balance;

      // Simulate failure on order insertion
      orderRepo.simulateInsertFailure = true;

      // Attempt immediate market buy order
      expect(
        () => placeBuyOrder(
          symbol: 'INFY',
          quantity: 10,
          price: Decimal.parse('1500.00'),
          orderType: OrderType.market,
          currentLtp: Decimal.parse('1500.00'),
        ),
        throwsA(isA<StorageException>()),
      );

      // Verify transaction rollback: wallet was NOT deducted
      final walletAfterFailure = await walletRepo.get();
      expect(walletAfterFailure.balance, initialBalance);
      expect(walletAfterFailure.totalInvested, Decimal.zero);

      // Verify transaction rollback: holding was NOT created
      final holding = await holdingsRepo.getBySymbol('INFY');
      expect(holding, isNull);

      // Verify no orders in repo
      expect((await orderRepo.getAll()).isEmpty, isTrue);
    });
  });
}
