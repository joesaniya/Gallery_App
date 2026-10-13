import 'package:flutter_test/flutter_test.dart';
import 'package:sam_gig/data/models/pixabay_image.dart';

import 'helpers/test_data.dart';

void main() {
  test('fromJson reads Pixabay keys and tolerates missing fields', () {
    final image = PixabayImage.fromJson({
      'id': 7,
      'tags': 'sea, wave',
      'webformatURL': 'https://example.com/w.jpg',
      'webformatWidth': 600,
      'webformatHeight': 300,
      'views': 10,
      
    });

    expect(image.id, 7);
    expect(image.tagList, ['sea', 'wave']);
    expect(image.aspectRatio, 2);
    expect(image.likes, 0);
    expect(image.user, '');
  });

  test('toJson -> fromJson round trip keeps the data', () {
    final original = buildImage(3);
    final copy = PixabayImage.fromJson(original.toJson());

    expect(copy, original);
    expect(copy.largeImageUrl, original.largeImageUrl);
    expect(copy.tags, original.tags);
  });

  test('description is composed from metadata', () {
    final description = buildImage(1).description;

    expect(description, contains('cat, pet, animal'));
    expect(description, contains('tester'));
    expect(description, contains('1.2K'));
  });

  test('aspectRatio falls back to 1 when size is unknown', () {
    final image = PixabayImage.fromJson({'id': 1});
    expect(image.aspectRatio, 1);
  });
}