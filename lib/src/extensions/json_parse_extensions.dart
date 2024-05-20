extension JsonIterableParseExtension on Iterable<dynamic> {
  List<T> parseList<T>(T Function(Map<String, Object?> json) fromJson) {
    return [
      for (final element in this) fromJson(element as Map<String, Object?>),
    ];
  }

  Iterable<T> parseIterable<T>(
      T Function(Map<String, Object?> json) fromJson) sync* {
    for (final element in this) {
      yield fromJson(element as Map<String, Object?>);
    }
  }
}
