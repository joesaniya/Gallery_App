class AppConfig {
  AppConfig._(); 

  static const String pixabayApiKey = String.fromEnvironment(
    'PIXABAY_API_KEY',
    defaultValue: '58020013-4f153a88a32c084c9804ad320',
  );
  static const String pixabayBaseUrl = 'https://pixabay.com';

  static const int pageSize = 30;

  static const Duration networkTimeout = Duration(seconds: 15);

 
  static const String downloadAlbum = 'Infinite Gallery';

 
  static const List<String> categories = [
    'nature',
    'animals',
    'travel',
    'food',
    'buildings',
    'science',
    'sports',
    'music',
    'business',
    'fashion',
  ];
}
