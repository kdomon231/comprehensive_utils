<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

## Features

Widgets

* FluentListView\<T>
* AsyncBuilder\<T>
* InitBuilder\<T>

Tools

* IndexingCollection\<T>
* ObservableTimer
* CacheManager
* Lazy\<T>

Streams

* DistinctSubject\<T>
* DistinctValueStream\<T>
* DistinctConnectableStream\<T>
* DistinctStreamCompleter\<T>
* ValueStreamCompleter\<T>

Implementation of numeric types

* Float
* Byte
* SByte
* Short
* UShort
* UInt
* ULong

Extensions

* on Stream:
    * publishDistinctValue
    * publishDistinctValueSeeded
    * shareDistinctValue
    * shareDistinctValueSeeded
    * mapDistinctValue\<R>
    * takeUntilFuture
    * firstWhereType\<R>

* on Future<bool?>
    * onSuccess
    * onFailure

* on Iterable:
    * parseList\<T>
    * parseIterable\<T>

* on Function:
    * apply

## Getting started

Add package import:

```dart
import 'package:comprehensive_utils/comprehensive_utils.dart';
```

## Usage

```dart

final DistinctSubject<String> _userNameSubject = DistinctSubject<String>();

DistinctValueStream<String> get userNameStream => _userNameSubject.stream;

void changeUserName(String userName) {
  // the value will be added to Stream if it differs from the previous one
  _userNameSubject.add(userName);
}
```
