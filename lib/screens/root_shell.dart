import 'package:flutter/material.dart';

import '../state/saved_stories_controller.dart';
import '../state/settings_controller.dart';
import 'home_screen.dart';
import 'saved_screen.dart';
import 'settings_screen.dart';

/// Bottom-nav shell hosting the Feed, Saved, and Settings tabs, replacing
/// the original app's ion-tabs.
class RootShell extends StatefulWidget {
  const RootShell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final _savedController = SavedStoriesController();
  final _settingsController = SettingsController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _savedController.load();
    _settingsController.load();
  }

  @override
  void dispose() {
    _savedController.dispose();
    _settingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        savedController: _savedController,
        settingsController: _settingsController,
        themeMode: widget.themeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
      ),
      SavedScreen(
        savedController: _savedController,
        settingsController: _settingsController,
      ),
      SettingsScreen(
        savedController: _savedController,
        settingsController: _settingsController,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: AnimatedBuilder(
        animation: _savedController,
        builder: (context, _) => NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.local_fire_department_outlined),
              selectedIcon: Icon(Icons.local_fire_department_rounded),
              label: 'Feed',
            ),
            NavigationDestination(
              icon: Badge(
                label: Text('${_savedController.saved.length}'),
                isLabelVisible: _savedController.saved.isNotEmpty,
                child: const Icon(Icons.bookmark_border_rounded),
              ),
              selectedIcon: const Icon(Icons.bookmark_rounded),
              label: 'Saved',
            ),
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
