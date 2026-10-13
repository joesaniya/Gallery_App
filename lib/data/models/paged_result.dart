class PagedResult<T> {
  const PagedResult({required this.items, required this.totalHits});

  final List<T> items;
  final int totalHits;
}
