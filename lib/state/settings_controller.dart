import 'package:flutter/foundation.dart';

import '../data/settings_store.dart';

/// Shared app settings (currently just the article link-opening mode).
class SettingsController extends ChangeNotifier {
  SettingsController({this._store = const SettingsStore()});

  final SettingsStore _store;
  bool _openInApp = true;

  bool get openInApp => _openInApp;

  Future<void> load() async {
    _openInApp = await _store.loadOpenInApp();
    notifyListeners();
  }

  Future<void> setOpenInApp(bool value) async {
    _openInApp = value;
    notifyListeners();
    await _store.saveOpenInApp(value);
  }
}
