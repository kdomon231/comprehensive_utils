import 'dart:async';

/// Extension on [Future<bool>] that provides methods for handling boolean results.
extension NullableBooleanFutureExtension on Future<bool?> {
  /// Calls the provided [callback] if the future completes with `true`.
  ///
  /// This method is useful for handling the success case of a boolean future.
  ///
  /// Example:
  /// ```dart
  /// Future<bool> myFuture = Future.value(true);
  /// myFuture.onSuccess(() {
  ///   print('Success!');
  /// });
  /// ```
  Future<void> onSuccess(FutureOr<void> Function() callback) async {
    if (await this == true) {
      await callback.call();
    }
  }

  /// Calls the provided [callback] if the future completes with `false`.
  ///
  /// This method is useful for handling the failure case of a boolean future.
  ///
  /// Example:
  /// ```dart
  /// Future<bool> myFuture = Future.value(false);
  /// myFuture.onFailure(() {
  ///   print('Failure!');
  /// });
  /// ```
  Future<void> onFailure(FutureOr<void> Function() callback) async {
    if (await this == false) {
      await callback.call();
    }
  }

  Future<void> onResult({
    required FutureOr<void> Function() onSuccess,
    required FutureOr<void> Function() onFailure,
    FutureOr<void> Function()? onNull,
  }) async => switch (await this) {
    true => await onSuccess.call(),
    false => await onFailure.call(),
    null => await onNull?.call(),
  };
}
