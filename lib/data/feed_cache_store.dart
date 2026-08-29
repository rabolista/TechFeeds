import 'package:shared_preferences/shared_preferences.dart';

/// Caches the last successfully fetched feed so the app has something
/// useful to show on next launch even if the network is unavailable —
/// distinct from the user-curated Saved list.
class FeedCacheStore {
  const FeedCacheStore();

  static const _key = 'techfeed.feedCache';

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> save(String rawJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, rawJson);
  }
}
