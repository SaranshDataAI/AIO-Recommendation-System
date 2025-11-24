import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models.dart';

class HistoryService {
  static const String _storageKey = 'watch_history_v1';

  /// Add or move an item to the top of history.
  static Future<void> addToHistory(ContentItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_storageKey) ?? <String>[];

    // Encode current item
    final map = <String, dynamic>{
      'id': item.id,
      'name': item.name,
      'type': item.type,
      'genres': item.genres,
      'overview': item.overview,
      'poster_url': item.posterUrl,
      'runtime': item.runtime,
    };
    final encoded = jsonEncode(map);

    // Remove any previous entry with same id
    existing.removeWhere((e) {
      try {
        final data = jsonDecode(e);
        return data['id'] == item.id;
      } catch (_) {
        return false;
      }
    });

    // Insert at top
    existing.insert(0, encoded);

    // Keep only last N items
    const maxItems = 40;
    if (existing.length > maxItems) {
      existing.removeRange(maxItems, existing.length);
    }

    await prefs.setStringList(_storageKey, existing);
  }

  /// Load history items, most recent first.
  static Future<List<ContentItem>> getHistory({int limit = 20}) async {
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
      if (items.length >= limit) break;
    }

    return items;
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
