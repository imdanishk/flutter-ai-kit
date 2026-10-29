/// A failure that can be shown to the user.
class AppFailure {
  const AppFailure(this.message);

  final String message;
}

/// The outcome of a repository call: either [Ok] with a value or [Err] with a failure.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final AppFailure failure;
}
