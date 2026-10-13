
import 'package:sam_gig/data/models/pixabay_image.dart';

PixabayImage buildImage(int id) => PixabayImage(
      id: id,
      pageUrl: 'https://pixabay.com/photos/$id',
      tags: 'cat, pet, animal',
      previewUrl: 'https://example.com/p$id.jpg',
      webformatUrl: 'https://example.com/w$id.jpg',
      webformatWidth: 640,
      webformatHeight: 480,
      largeImageUrl: 'https://example.com/l$id.jpg',
      views: 1200,
      likes: 30,
      downloads: 400,
      comments: 2,
      user: 'tester',
      userImageUrl: '',
    );