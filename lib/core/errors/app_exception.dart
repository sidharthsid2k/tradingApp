/// Domain error types. Thrown by use-cases and caught at the ViewModel layer.
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Persistence / database failures.
class StorageException extends AppException {
  const StorageException(super.message);
}

/// Business-rule violations (e.g. insufficient balance).
class BusinessException extends AppException {
  const BusinessException(super.message);
}

/// Validation failures (e.g. invalid quantity).
class ValidationException extends AppException {
  const ValidationException(super.message);
}

/// Item not found in repository.
class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
