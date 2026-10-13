import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/config/app_config.dart';
import '../../core/error/app_exception.dart';
import '../models/pixabay_image.dart';


class DownloadService {
  DownloadService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<void> saveToGallery(
    PixabayImage image, {
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    
    try {
      if (!await Gal.hasAccess(toAlbum: true)) {
        final granted = await Gal.requestAccess(toAlbum: true);
        if (!granted) throw const PermissionException();
      }
    } on GalException {
      throw const PermissionException();
    }

    
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pixabay_${image.id}.jpg');

    try {
      await _dio.download(
        image.largeImageUrl,
        file.path,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
        
          if (total > 0) onProgress?.call(received / total);
        },
      );

      
      await Gal.putImage(file.path, album: AppConfig.downloadAlbum);
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        throw const DownloadException('Download cancelled.');
      }
      throw const DownloadException(
        'Download failed. Check your connection and try again.',
      );
    } on GalException catch (e) {
      if (e.type == GalExceptionType.accessDenied) {
        throw const PermissionException();
      }
      throw const DownloadException(
        'Could not save the image to your gallery.',
      );
    } finally {
      
      if (await file.exists()) await file.delete();
    }
  }
}
