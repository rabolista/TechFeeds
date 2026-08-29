import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/story.dart';

/// Persists bookmarked stories on-device for offline reading, matching the
/// `techfeed.saved` localStorage behavior of the original app.
class SavedStoriesStore {
  const SavedStoriesStore();

  static const _key = 'techfeed.saved';

  Future<List<Story>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .cast<Map<String, dynamic>>()
          .map(Story.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Story> stories) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(stories.map((s) => s.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
