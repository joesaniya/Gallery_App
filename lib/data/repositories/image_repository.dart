import '../models/paged_result.dart';
import '../models/pixabay_image.dart';
import '../services/pixabay_api_service.dart';


abstract class ImageRepository {
  Future<PagedResult<PixabayImage>> fetchImages({
    required int page,
    required int perPage,
    String query = '',
    String? category,
  });
}

class PixabayImageRepository implements ImageRepository {
  PixabayImageRepository(this._api);

  final PixabayApiService _api;

  @override
  Future<PagedResult<PixabayImage>> fetchImages({
    required int page,
    required int perPage,
    String query = '',
    String? category,
  }) {
    
    return _api.fetchImages(
      page: page,
      perPage: perPage,
      query: query.trim(),
      category: category,
    );
  }
}
