import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/error/app_exception.dart';
import '../models/pixabay_image.dart';


class FavoritesStorage {
  FavoritesStorage(this._prefs);

  static const _key = 'favorites_v1'; 
  final SharedPreferences _prefs;

  List<PixabayImage> read() {
    final raw = _prefs.getStringList(_key) ?? const <String>[];
    final result = <PixabayImage>[];
    for (final item in raw) {
      try {
        result.add(
          PixabayImage.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      } catch (_) {
     
      }
    }
    return result;
  }

  Future<void> write(List<PixabayImage> images) async {
    final ok = await _prefs.setStringList(
      _key,
      images.map((i) => jsonEncode(i.toJson())).toList(),
    );
    if (!ok) throw const StorageException();
  }
}
