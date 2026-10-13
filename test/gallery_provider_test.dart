import 'package:flutter_test/flutter_test.dart';
import 'package:sam_gig/core/error/app_exception.dart';
import 'package:sam_gig/data/models/paged_result.dart';
import 'package:sam_gig/data/repositories/image_repository.dart';
import 'package:sam_gig/presentation/providers/gallery_provider.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/test_data.dart';

class MockImageRepository extends Mock implements ImageRepository {}

void main() {
  late MockImageRepository repo;
  late GalleryProvider provider;

  setUp(() {
    repo = MockImageRepository();
    provider = GalleryProvider(repo, perPage: 2);
  });


  void stubPage(int page, List<int> ids, {int total = 5, String query = ''}) {
    when(() => repo.fetchImages(page: page, perPage: 2, query: query, category: null))
        .thenAnswer(
      (_) async => PagedResult(items: ids.map(buildImage).toList(), totalHits: total),
    );
  }

  test('loadInitial fetches the first page', () async {
    stubPage(1, [1, 2]);

    await provider.loadInitial();

    expect(provider.images.map((i) => i.id), [1, 2]);
    expect(provider.isInitialLoading, isFalse);
    expect(provider.hasReachedMax, isFalse);
    expect(provider.error, isNull);
  });

  test('loadMore appends pages and flags the end of the list', () async {
    stubPage(1, [1, 2]);
    stubPage(2, [3, 4]);
    stubPage(3, [5]);

    await provider.loadInitial();
    await provider.loadMore();
    expect(provider.images.length, 4);
    expect(provider.hasReachedMax, isFalse);

    await provider.loadMore();
    expect(provider.images.length, 5);
    expect(provider.hasReachedMax, isTrue);
  });

  test('does not request more pages after reaching the end', () async {
    stubPage(1, [1, 2], total: 2);

    await provider.loadInitial();
    expect(provider.hasReachedMax, isTrue);

    await provider.loadMore();
    verifyNever(() => repo.fetchImages(page: 2, perPage: 2, query: '', category: null));
  });

  test('exposes a full-screen error when the first page fails', () async {
    when(() => repo.fetchImages(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          query: any(named: 'query'),
          category: any(named: 'category'),
        )).thenThrow(const NetworkException());

    await provider.loadInitial();

    expect(provider.error, isA<NetworkException>());
    expect(provider.images, isEmpty);
    expect(provider.isInitialLoading, isFalse);
  });

  test('keeps loaded images and exposes loadMoreError when a later page fails', () async {
    stubPage(1, [1, 2]);
    when(() => repo.fetchImages(page: 2, perPage: 2, query: '', category: null))
        .thenThrow(const ServerException());

    await provider.loadInitial();
    await provider.loadMore();

    expect(provider.images.length, 2);
    expect(provider.loadMoreError, isA<ServerException>());
    expect(provider.error, isNull);
  });

  test('search resets the list with new results', () async {
    stubPage(1, [1, 2]);
    stubPage(1, [9], total: 1, query: 'cats');

    await provider.loadInitial();
    await provider.search('cats');

    expect(provider.images.map((i) => i.id), [9]);
    expect(provider.query, 'cats');
  });
}