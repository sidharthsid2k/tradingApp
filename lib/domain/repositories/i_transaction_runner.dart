/// Contract for executing multiple repository mutations within an atomic database transaction.
abstract interface class ITransactionRunner {
  /// Executes [action] inside a single database transaction.
  ///
  /// If any error occurs inside [action], all database mutations are rolled back.
  Future<T> run<T>(Future<T> Function() action);
}
