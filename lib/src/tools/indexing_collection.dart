import 'dart:collection';
import 'package:collection/collection.dart';

/// A class representing a collection of items with integer keys.
///
/// This class provides methods to add, remove, and clear items from the collection.
/// It also allows accessing items using their keys.
class IndexingCollection<T> {
  IndexingCollection();

  // A map that stores the items, with their keys being integers.
  final HashMap<int, T> _hashMap = HashMap<int, T>();

  // A queue that stores the keys of the items that have been removed from the collection.
  // These keys can be reused for new items.
  final QueueList<int> _releasedIds = QueueList<int>();

  // A counter that is used to generate new keys for the items.
  int _counter = 0;

  /// Accesses the item with the given key from the collection.
  ///
  /// Returns `null` if no item with the given key exists in the collection.
  T? operator [](int key) => _hashMap[key];

  /// Adds a new item to the collection and returns its key.
  ///
  /// If there are released keys in the queue, a new item is added using one of those keys.
  ///
  /// Returns the key assigned to the new item.
  int add(T value) {
    final id = _releasedIds.isEmpty ? ++_counter : _releasedIds.removeFirst();
    _hashMap[id] = value;
    return id;
  }

  /// Removes the item with the given key from the collection and returns its value.
  ///
  /// If the item was successfully removed, its key is added to the queue of released keys.
  ///
  /// Returns the value of the removed item, or `null` if no item with the given key exists.
  T? remove(int key) {
    final value = _hashMap.remove(key);
    if (value != null) {
      _releasedIds.add(key);
    }
    return value;
  }

  /// Clears the collection, removing all items and resetting the counter.
  void clear() {
    _hashMap.clear();
    _releasedIds.clear();
    _counter = 0;
  }
}
