import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProService {
  final SharedPreferences _prefs;
  final ValueNotifier<bool> isPro;
  final Set<String> favorites;

  ProService._(this._prefs, bool pro)
      : isPro = ValueNotifier(pro),
        favorites = (_prefs.getStringList('favorites') ?? <String>[]).toSet();

  static Future<ProService> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ProService._(prefs, prefs.getBool('is_pro') ?? false);
  }

  /// Демо-разблокировка. В продакшене заменить на реальный биллинг.
  Future<void> unlockProDemo() async {
    await _prefs.setBool('is_pro', true);
    isPro.value = true;
  }

  bool isFavorite(String movieId) => favorites.contains(movieId);

  Future<void> toggleFavorite(String movieId) async {
    if (!isPro.value) return;

    if (favorites.contains(movieId)) {
      favorites.remove(movieId);
    } else {
      favorites.add(movieId);
    }

    await _prefs.setStringList('favorites', favorites.toList());
  }
}
