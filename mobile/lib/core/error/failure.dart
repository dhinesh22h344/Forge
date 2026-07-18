/// Failure types surfaced from the domain/data layers to the presentation
/// layer. Kept as a plain sealed class (no external package) since the only
/// consumer is [Result] — see result.dart.
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors = const {}});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired, please log in again']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local data unavailable']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
