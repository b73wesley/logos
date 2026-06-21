sealed class Response<T> {
  const Response();

  const factory Response.success(T data) = Success._;
  const factory Response.failure(Object error) = Failure._;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  /// Unwraps data on success, returns null on failure.
  T? get dataOrNull => switch (this) {
    Success<T> s => s.data,
    Failure<T> _ => null,
  };

  /// Runs [onSuccess] or [onFailure] and returns the result.
  R when<R>({required R Function(T data) onSuccess, required R Function(Object error) onFailure}) =>
      switch (this) {
        Success<T> s => onSuccess(s.data),
        Failure<T> f => onFailure(f.error),
      };
}

final class Success<T> extends Response<T> {
  const Success._(this.data);
  final T data;

  @override
  String toString() => 'Success($data)';
}

final class Failure<T> extends Response<T> {
  const Failure._(this.error);
  final Object error;

  @override
  String toString() => 'Failure($error)';
}
