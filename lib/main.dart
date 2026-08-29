import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/root_shell.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TechAndFeedsApp());
}

/// Root widget for the Tech and Feeds app (v1.5).
class TechAndFeedsApp extends StatefulWidget {
  const TechAndFeedsApp({super.key});

  @override
  State<TechAndFeedsApp> createState() => _TechAndFeedsAppState();
}

class _TechAndFeedsAppState extends State<TechAndFeedsApp> {
  static const _themeModePrefKey = 'themeMode';
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeModePrefKey);
    setState(() {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == saved,
        orElse: () => ThemeMode.system,
      );
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefKey, mode.name);
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tech and Feeds',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: RootShell(
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}
