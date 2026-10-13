import 'package:flutter/foundation.dart';

import '../../core/utils/formatters.dart';


@immutable
class PixabayImage {
  const PixabayImage({
    required this.id,
    required this.pageUrl,
    required this.tags,
    required this.previewUrl,
    required this.webformatUrl,
    required this.webformatWidth,
    required this.webformatHeight,
    required this.largeImageUrl,
    required this.views,
    required this.likes,
    required this.downloads,
    required this.comments,
    required this.user,
    required this.userImageUrl,
  });

  final int id;
  final String pageUrl;
  final String tags; 
  final String previewUrl; 
  final String webformatUrl; 
  final int webformatWidth;
  final int webformatHeight;
  final String largeImageUrl; 
  final int views;
  final int likes;
  final int downloads;
  final int comments;
  final String user;
  final String userImageUrl;

  factory PixabayImage.fromJson(Map<String, dynamic> json) {
   
    int asInt(String key) => (json[key] as num?)?.toInt() ?? 0;
    String asString(String key) => json[key] as String? ?? '';

    return PixabayImage(
      id: asInt('id'),
      pageUrl: asString('pageURL'),
      tags: asString('tags'),
      previewUrl: asString('previewURL'),
      webformatUrl: asString('webformatURL'),
      webformatWidth: asInt('webformatWidth'),
      webformatHeight: asInt('webformatHeight'),
      largeImageUrl: asString('largeImageURL'),
      views: asInt('views'),
      likes: asInt('likes'),
      downloads: asInt('downloads'),
      comments: asInt('comments'),
      user: asString('user'),
      userImageUrl: asString('userImageURL'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'pageURL': pageUrl,
    'tags': tags,
    'previewURL': previewUrl,
    'webformatURL': webformatUrl,
    'webformatWidth': webformatWidth,
    'webformatHeight': webformatHeight,
    'largeImageURL': largeImageUrl,
    'views': views,
    'likes': likes,
    'downloads': downloads,
    'comments': comments,
    'user': user,
    'userImageURL': userImageUrl,
  };

  
  double get aspectRatio => (webformatWidth <= 0 || webformatHeight <= 0)
      ? 1
      : webformatWidth / webformatHeight;

  List<String> get tagList =>
      tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();


  String get description {
    final subjects = tagList.take(3).join(', ');
    final topic = subjects.isEmpty
        ? 'an image'
        : 'an image featuring $subjects';
    return 'This is $topic, shared by $user on Pixabay. '
        'It has been viewed ${formatCount(views)} times and liked by '
        '${formatCount(likes)} people.';
  }


  @override
  bool operator ==(Object other) => other is PixabayImage && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
