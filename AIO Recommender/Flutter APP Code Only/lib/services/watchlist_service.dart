import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models.dart';

class WatchlistService {
  static const String _storageKey = 'watchlist_v1';

  static Future<List<ContentItem>> getWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storageKey) ?? <String>[];
    final items = <ContentItem>[];

    for (final entry in stored) {
      try {
        final data = jsonDecode(entry);
        items.add(
          ContentItem(
            id: data['id'] is int
                ? data['id']
                : int.tryParse('${data['id']}') ?? 0,
            name: data['name']?.toString() ?? '',
            type: data['type']?.toString() ?? '',
            genres: data['genres']?.toString() ?? '',
            overview: data['overview']?.toString() ?? '',
            posterUrl: data['poster_url']?.toString() ?? '',
            runtime: data['runtime'] == null
                ? null
                : (data['runtime'] is num
                    ? (data['runtime'] as num).toDouble()
                    : double.tryParse('${data['runtime']}')),
          ),
        );
      } catch (_) {
        // ignore broken entries
      }
    }

    return items;
  }

  static Future<bool> isInWatchlist(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storageKey) ?? <String>[];

    for (final entry in stored) {
      try {
        final data = jsonDecode(entry);
        if (data['id'] == id) return true;
      } catch (_) {}
    }
    return false;
  }

  static Future<void> toggleWatchlist(ContentItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_storageKey) ?? <String>[];

    bool removed = false;
    stored.removeWhere((entry) {
      try {
        final data = jsonDecode(entry);
        if (data['id'] == item.id) {
          removed = true;
          return true;
        }
      } catch (_) {}
      return false;
    });

    if (!removed) {
      final map = <String, dynamic>{
        'id': item.id,
        'name': item.name,
        'type': item.type,
        'genres': item.genres,
        'overview': item.overview,
        'poster_url': item.posterUrl,
        'runtime': item.runtime,
      };
      stored.insert(0, jsonEncode(map));
    }

    await prefs.setStringList(_storageKey, stored);
  }

  static Future<void> clearWatchlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
