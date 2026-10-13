import 'package:flutter_test/flutter_test.dart';
import 'package:sam_gig/data/services/favorites_storage.dart';
import 'package:sam_gig/presentation/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_data.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({}); 
    prefs = await SharedPreferences.getInstance();
  });

  test('toggle adds then removes a favorite', () async {
    final provider = FavoritesProvider(FavoritesStorage(prefs));
    final image = buildImage(1);

    expect(await provider.toggle(image), isTrue);
    expect(provider.isFavorite(1), isTrue);
    expect(provider.count, 1);

    expect(await provider.toggle(image), isTrue);
    expect(provider.isFavorite(1), isFalse);
  });

  test('favorites persist across provider instances (app restart)', () async {
    final first = FavoritesProvider(FavoritesStorage(prefs));
    await first.toggle(buildImage(1));
    await first.toggle(buildImage(2));

    final second = FavoritesProvider(FavoritesStorage(prefs));

    expect(second.favorites.map((i) => i.id), [2, 1]); 
  });
}
