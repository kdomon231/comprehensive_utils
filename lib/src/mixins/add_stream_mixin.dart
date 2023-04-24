import 'dart:async';

mixin AddStreamMixin<T> {
  bool _isAddingStreamItems = false;

  bool get isAddingStreamItems => _isAddingStreamItems;

  Future<void> addStream(
    Stream<T> source,
    void Function(T) add,
    void Function(Object error, [StackTrace? stackTrace]) addError, {
    bool? cancelOnError,
  }) {
    if (_isAddingStreamItems) {
      throw StateError(
        'You cannot add items while items are being added from addStream',
      );
    }
    _isAddingStreamItems = true;

    final completer = Completer<void>();
    void complete() {
      if (!completer.isCompleted) {
        _isAddingStreamItems = false;
        completer.complete();
      }
    }

    source.listen(
      add,
      onError: (cancelOnError ?? false)
          ? (Object e, StackTrace s) {
              addError(e, s);
              complete();
            }
          : addError,
      onDone: complete,
      cancelOnError: cancelOnError,
    );

    return completer.future;
  }
}
