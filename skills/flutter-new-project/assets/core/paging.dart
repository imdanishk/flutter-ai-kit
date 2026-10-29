/// One page of items and whether more pages follow.
class PageResult<T> {
  const PageResult({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;
}

int _bound(int value, int max) {
  if (value < 0) return 0;
  if (value > max) return max;
  return value;
}

/// The items from [offset] up to [limit] items, plus whether items remain after them.
PageResult<T> slicePage<T>(
  List<T> all, {
  required int offset,
  required int limit,
}) {
  final start = _bound(offset, all.length);
  final end = _bound(offset + limit, all.length);
  return PageResult<T>(
    items: all.sublist(start, end),
    hasMore: end < all.length,
  );
}
