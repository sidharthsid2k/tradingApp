import '../../domain/repositories/i_transaction_runner.dart';
import '../datasources/local/app_database.dart';

/// Implements [ITransactionRunner] using SQLite/Drift's native atomic transaction block.
class TransactionRunnerImpl implements ITransactionRunner {
  const TransactionRunnerImpl(this._db);

  final AppDatabase _db;

  @override
  Future<T> run<T>(Future<T> Function() action) => _db.transaction(action);
}
