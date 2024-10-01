import 'package:flutter/services.dart';

/// Extension on [Future<bool>] that provides methods for handling boolean results.
extension OnBooleanResult on Future<bool> {
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
  Future<void> onSuccess(VoidCallback callback) async {
    if (await this) {
      callback.call();
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
  Future<void> onFailure(VoidCallback callback) async {
    if (!(await this)) {
      callback.call();
    }
  }
}