import 'package:flutter/material.dart';

import '../state/saved_stories_controller.dart';
import '../state/settings_controller.dart';
import 'about_page.dart';

/// Preferences tab: link-opening mode and saved-articles management,
/// matching the original app's Settings tab.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.savedController,
    required this.settingsController,
  });

  final SavedStoriesController savedController;
  final SettingsController settingsController;

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear saved articles?'),
        content: const Text('This removes all saved headlines from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await savedController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([settingsController, savedController]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              SwitchListTile(
                title: const Text('Open articles inside the app'),
                subtitle: const Text('Turn off to open links in your default browser'),
                value: settingsController.openInApp,
                onChanged: settingsController.setOpenInApp,
              ),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: Text(
                  'Clear saved articles (${savedController.saved.length})',
                ),
                onTap: savedController.saved.isEmpty
                    ? null
                    : () => _confirmClear(context),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('About Tech and Feeds'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Tech and Feeds keeps your saved headlines on this device '
                  'for offline reading, and lets you filter, search and '
                  'share stories natively.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
