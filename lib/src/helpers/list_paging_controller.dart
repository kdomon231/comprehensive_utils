import 'package:comprehensive_utils/src/helpers/list_paging_notifier.dart';
import 'package:flutter/foundation.dart';

final class ListPagingController {
  ListPagingController();

  ListPagingNotifier? _notifier;

  int? get currentPage => _notifier?.pageNumber;

  Future<void> reset() async => await _notifier?.refresh();

  @internal
  // ignore: use_setters_to_change_properties
  void attach(ListPagingNotifier notifier) => _notifier = notifier;

  @internal
  void detach() => _notifier = null;
}
