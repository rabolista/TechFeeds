import 'package:shared_preferences/shared_preferences.dart';

/// Persists user preferences, matching the `techfeed.settings` key of the
/// original app.
class SettingsStore {
  const SettingsStore();

  static const _openInAppKey = 'techfeed.settings.openInApp';

  Future<bool> loadOpenInApp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_openInAppKey) ?? true;
  }

  Future<void> saveOpenInApp(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_openInAppKey, value);
  }
}
