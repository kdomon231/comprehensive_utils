extension JsonIterableParseExtension on Iterable<dynamic> {
  List<T> parseList<T>(T Function(Map<String, Object?> json) fromJson) {
    return [
      for (final element in this) fromJson(element as Map<String, Object?>)
    ];
  }
}
