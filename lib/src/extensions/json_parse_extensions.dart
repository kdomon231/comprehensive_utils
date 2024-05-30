/// Extension on [Iterable] that provides methods for parsing JSON data.
extension JsonIterableParseExtension on Iterable<dynamic> {
  /// Parses an iterable of JSON objects into a list of Dart objects.
  ///
  /// The [fromJson] function should take a [Map<String, Object?>] and return a Dart object.
  /// This function is used to convert each JSON object in the iterable into a Dart object.
  ///
  /// Returns a list of Dart objects.
  List<T> parseList<T>(T Function(Map<String, Object?> json) fromJson) {
    return [
      for (final element in this) fromJson(element as Map<String, Object?>),
    ];
  }

  /// Parses an iterable of JSON objects into an iterable of Dart objects.
  ///
  /// The [fromJson] function should take a [Map<String, Object?>] and return a Dart object.
  /// This function is used to convert each JSON object in the iterable into a Dart object.
  ///
  /// Returns an iterable of Dart objects.
  Iterable<T> parseIterable<T>(
      T Function(Map<String, Object?> json) fromJson) sync* {
    for (final element in this) {
      yield fromJson(element as Map<String, Object?>);
    }
  }
}
