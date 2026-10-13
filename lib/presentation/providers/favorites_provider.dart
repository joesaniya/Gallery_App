import 'package:flutter/foundation.dart';

import '../../data/models/pixabay_image.dart';
import '../../data/services/favorites_storage.dart';


class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._storage) {
    
    for (final image in _storage.read()) {
      _favorites[image.id] = image;
    }
  }

  final FavoritesStorage _storage;

  
  final Map<int, PixabayImage> _favorites = {};

  int get count => _favorites.length;
  bool isFavorite(int id) => _favorites.containsKey(id);

 
  List<PixabayImage> get favorites =>
      _favorites.values.toList().reversed.toList();

 
  Future<bool> toggle(PixabayImage image) async {
    final wasFavorite = _favorites.containsKey(image.id);

   
    if (wasFavorite) {
      _favorites.remove(image.id);
    } else {
      _favorites[image.id] = image;
    }
    notifyListeners();

    try {
      await _storage.write(_favorites.values.toList());
      return true;
    } catch (_) {
      if (wasFavorite) {
        _favorites[image.id] = image;
      } else {
        _favorites.remove(image.id);
      }
      notifyListeners();
      return false;
    }
  }
}
