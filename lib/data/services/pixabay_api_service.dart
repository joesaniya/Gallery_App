import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../core/error/app_exception.dart';
import '../models/paged_result.dart';
import '../models/pixabay_image.dart';

class PixabayApiService {
  PixabayApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.pixabayBaseUrl,
              connectTimeout: AppConfig.networkTimeout,
              receiveTimeout: AppConfig.networkTimeout,
            ),
          );

  final Dio _dio;

  Future<PagedResult<PixabayImage>> fetchImages({
    required int page,
    required int perPage,
    String query = '',
    String? category,
  }) async {
   
    if (AppConfig.pixabayApiKey.isEmpty) throw const ApiKeyException();

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/',
        queryParameters: {
          'key': AppConfig.pixabayApiKey,
          if (query.isNotEmpty) 'q': query,
          if (category != null) 'category': category,
          'image_type': 'photo',
          'order': 'popular',
          'safesearch': true,
          'page': page,
          'per_page': perPage,
        },
      );

      final data = response.data;
      if (data == null) throw const ServerException();

      try {
        final hits = (data['hits'] as List<dynamic>)
            .map((e) => PixabayImage.fromJson(e as Map<String, dynamic>))
            .toList();
        final total = (data['totalHits'] as num?)?.toInt() ?? hits.length;
        return PagedResult(items: hits, totalHits: total);
      } catch (_) {
       
        throw const ServerException();
      }
    } on DioException catch (e) {
      
      if (_isPageOutOfRange(e)) {
        return const PagedResult(items: [], totalHits: 0);
      }
      throw _mapDioError(e);
    }
  }

  bool _isPageOutOfRange(DioException e) {
    if (e.response?.statusCode != 400) return false;
    return (e.response?.data?.toString() ?? '').toLowerCase().contains(
      'out of valid range',
    );
  }

  AppException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 429) return const RateLimitException();
        if (status == 401 || status == 403) return const ApiKeyException();
        final body = (e.response?.data?.toString() ?? '').toLowerCase();
        if (status == 400 && body.contains('key')) {
          return const ApiKeyException();
        }
        return const ServerException();
      default:
        return const UnknownException();
    }
  }
}
