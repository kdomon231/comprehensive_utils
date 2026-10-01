import 'package:comprehensive_utils/src/common/typedefs.dart';
import 'package:comprehensive_utils/src/helpers/list_paging_controller.dart';
import 'package:flutter/foundation.dart';

final class ListPagingNotifier extends ValueNotifier<bool> {
  ListPagingNotifier(this._loadNextPage, this.pageSize, this._pagingController) : super(false) {
    _pagingController?.attach(this);
    load();
  }

  final LoadNextPage _loadNextPage;
  final int pageSize;
  final ListPagingController? _pagingController;
  int pageNumber = 1;

  Future<void> loadNextPage() async {
    if (!value) {
      value = true;
      await load();
    }
  }

  Future<void> load() async {
    if (await _loadNextPage(pageNumber, pageSize)) {
      pageNumber++;
    }
    value = false;
  }

  Future<void> refresh() async {
    pageNumber = 1;
    await load();
  }

  @override
  void dispose() {
    _pagingController?.detach();
    super.dispose();
  }
}
