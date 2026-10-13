
abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException()
      : super('No internet connection. Check your network and try again.');
}

class RateLimitException extends AppException {
  const RateLimitException()
      : super('Too many requests. Please wait a minute and try again.');
}

class ApiKeyException extends AppException {
  const ApiKeyException()
      : super('Missing or invalid Pixabay API key. Run the app with '
            '--dart-define=PIXABAY_API_KEY=your_key');
}

class ServerException extends AppException {
  const ServerException()
      : super('The image service is having trouble. Please try again later.');
}

class PermissionException extends AppException {
  const PermissionException()
      : super('Permission denied. Allow photo access in Settings to save images.');
}

class DownloadException extends AppException {
  const DownloadException([super.message = 'Download failed. Please try again.']);
}

class StorageException extends AppException {
  const StorageException()
      : super('Could not save your changes on this device.');
}

class UnknownException extends AppException {
  const UnknownException() : super('Something went wrong. Please try again.');
}