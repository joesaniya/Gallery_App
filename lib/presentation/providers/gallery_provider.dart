import 'dart:collection';

import 'package:flutter/foundation.dart';
import '../../core/config/app_config.dart';
import '../../core/error/app_exception.dart';
import '../../data/models/paged_result.dart';
import '../../data/models/pixabay_image.dart';
import '../../data/repositories/image_repository.dart';


class GalleryProvider extends ChangeNotifier {
  GalleryProvider(this._repository, {this.perPage = AppConfig.pageSize});

  final ImageRepository _repository;
  final int perPage;

  final List<PixabayImage> _images = [];
  int _nextPage = 1;
  int _generation = 0;
  String _query = '';
  String? _category; 

  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;
  AppException? _error; 
  AppException? _loadMoreError; 


  List<PixabayImage> get images => UnmodifiableListView(_images);
  String get query => _query;
  String? get category => _category;
  bool get isInitialLoading => _isInitialLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasReachedMax => _hasReachedMax;
  AppException? get error => _error;
  AppException? get loadMoreError => _loadMoreError;


  Future<void> loadInitial() => _loadFirstPage(showSkeleton: true);


  Future<AppException?> refresh() => _loadFirstPage(showSkeleton: false);

  Future<void> search(String query) {
    final trimmed = query.trim();
    if (trimmed == _query) return Future.value();
    _query = trimmed;
    return loadInitial();
  }

  Future<void> selectCategory(String? category) {
    if (category == _category) return Future.value();
    _category = category;
    return loadInitial();
  }


  Future<void> loadMore() async {
    if (_isInitialLoading ||
        _isLoadingMore ||
        _hasReachedMax ||
        _images.isEmpty) {
      return;
    }

    final generation = _generation;
    final page = _nextPage;
    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    final outcome = await _request(page);


    if (generation != _generation) return;

    if (outcome.result != null) {
      _append(outcome.result!, page);
    } else {
      _loadMoreError = outcome.failure;
    }
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<AppException?> _loadFirstPage({required bool showSkeleton}) async {
    final generation = ++_generation; 
    _isLoadingMore = false;
    _loadMoreError = null;
    if (showSkeleton) {
      _images.clear();
      _nextPage = 1;
      _hasReachedMax = false;
      _error = null;
      _isInitialLoading = true;
    }
    notifyListeners();

    final outcome = await _request(1);
    if (generation != _generation) return null;

    if (outcome.result != null) {
      _images.clear();
      _append(outcome.result!, 1);
      _error = null;
    } else if (showSkeleton) {
      _error = outcome.failure;
    }
    _isInitialLoading = false;
    notifyListeners();
    return outcome.failure;
  }


  void _append(PagedResult<PixabayImage> result, int fetchedPage) {
    final known = _images.map((i) => i.id).toSet();
    _images.addAll(result.items.where((i) => known.add(i.id)));
    _nextPage = fetchedPage + 1;
    
    _hasReachedMax =
        result.items.isEmpty || fetchedPage * perPage >= result.totalHits;
  }

 
  Future<({PagedResult<PixabayImage>? result, AppException? failure})> _request(
    int page,
  ) async {
    try {
      final result = await _repository.fetchImages(
        page: page,
        perPage: perPage,
        query: _query,
        category: _category,
      );
      return (result: result, failure: null);
    } on AppException catch (e) {
      return (result: null, failure: e);
    } catch (_) {
      return (result: null, failure: const UnknownException());
    }
  }
}
