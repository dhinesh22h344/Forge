import 'failure.dart';

/// Lightweight Either-style result so use cases and repositories never throw
/// across layer boundaries. Deliberately hand-rolled instead of pulling in
/// `dartz`/`fpdart` — Forge only needs the two-case success/failure shape,
/// not a full functional-programming toolkit.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) return success(self.data);
    if (self is Error<T>) return failure(self.failure);
    throw StateError('Unreachable');
  }

  bool get isSuccess => this is Success<T>;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
