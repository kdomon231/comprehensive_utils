import 'package:comprehensive_utils/src/streams/get_stream.dart';

class Node<T> {
  Node({required this.data, this.next});

  T data;
  Node<T>? next;
}

class MiniSubscription<T> {
  const MiniSubscription(
    this.data,
    this.onError,
    this.onDone,
    this.listener, {
    this.cancelOnError = false,
  });

  final OnData<T> data;
  final Function? onError;
  final Callback? onDone;
  final bool cancelOnError;

  Future<void> cancel() async => listener?.removeListener(this);

  final FastList<T>? listener;
}

class MiniStream<T> {
  FastList<T>? listenable = FastList<T>();

  Object? _value;

  T get value => _value as T;

  set value(T val) {
    add(val);
  }

  void add(T event) {
    assert(listenable != null, 'listenable null');
    _value = event;
    listenable!._notifyData(event);
  }

  void addError(Object error, [StackTrace? stackTrace]) {
    assert(listenable != null, 'listenable null');
    listenable!._notifyError(error, stackTrace);
  }

  int get length => listenable?.length ?? -1;

  bool get hasListeners => listenable?.isNotEmpty ?? false;

  bool get isClosed => listenable == null;

  MiniSubscription<T> listen(
    void Function(T event) onData, {
    Function? onError,
    void Function()? onDone,
    bool cancelOnError = false,
  }) {
    final subs = MiniSubscription<T>(
      onData,
      onError,
      onDone,
      cancelOnError: cancelOnError,
      listenable,
    );
    listenable?.addListener(subs);
    return subs;
  }

  void close() {
    if (listenable == null) {
      throw StateError('You can not close a closed Stream');
    }
    listenable!._notifyDone();
    listenable = null;
    _value = null;
  }
}

class FastList<T> {
  Node<MiniSubscription<T>>? _head;

  void _notifyData(T data) {
    Node<MiniSubscription<T>>? currentNode = _head;
    do {
      currentNode?.data.data(data);
      currentNode = currentNode?.next;
    } while (currentNode != null);
  }

  void _notifyDone() {
    Node<MiniSubscription<T>>? currentNode = _head;
    do {
      currentNode?.data.onDone?.call();
      currentNode = currentNode?.next;
    } while (currentNode != null);
  }

  void _notifyError(Object error, [StackTrace? stackTrace]) {
    Node<MiniSubscription<T>>? currentNode = _head;
    while (currentNode != null) {
      // ignore: avoid_dynamic_calls
      currentNode.data.onError?.call(error, stackTrace);
      currentNode = currentNode.next;
    }
  }

  /// Checks if this list is empty
  bool get isEmpty => _head == null;

  bool get isNotEmpty => !isEmpty;

  /// Returns the length of this list
  int get length {
    var length = 0;
    var currentNode = _head;

    while (currentNode != null) {
      currentNode = currentNode.next;
      length++;
    }
    return length;
  }

  /// Shows the element at position [position]. `null` for invalid positions.
  MiniSubscription<T>? _elementAt(int position) {
    if (isEmpty || length < position || position < 0) {
      return null;
    }

    var node = _head;
    var current = 0;

    while (current != position) {
      node = node?.next;
      current++;
    }
    return node?.data;
  }

  /// Inserts [data] at the end of the list.
  void addListener(MiniSubscription<T> data) {
    final newNode = Node(data: data);

    if (isEmpty) {
      _head = newNode;
    } else {
      Node<MiniSubscription<T>> currentNode = _head!;
      while (currentNode.next != null) {
        currentNode = currentNode.next!;
      }
      currentNode.next = newNode;
    }
  }

  bool contains(T element) {
    final length = this.length;
    for (var i = 0; i < length; i++) {
      if (_elementAt(i) == element) {
        return true;
      }
      if (length != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
    return false;
  }

  void removeListener(MiniSubscription<T> element) {
    final length = this.length;
    for (var i = 0; i < length; i++) {
      if (_elementAt(i) == element) {
        _removeAt(i);
        break;
      }
    }
  }

  MiniSubscription<T>? _removeAt(int position) {
    var index = 0;
    var currentNode = _head;
    Node<MiniSubscription<T>>? previousNode;

    if (isEmpty || length < position || position < 0) {
      throw Exception('Invalid position');
    } else if (position == 0) {
      _head = _head!.next;
    } else {
      while (index != position) {
        previousNode = currentNode;
        currentNode = currentNode?.next;
        index++;
      }

      if (previousNode == null) {
        _head = null;
      } else {
        previousNode.next = currentNode?.next;
      }

      currentNode?.next = null;
    }

    return currentNode?.data;
  }
}
