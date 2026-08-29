import 'package:flutter/material.dart';

import '../state/saved_stories_controller.dart';
import '../state/settings_controller.dart';
import '../utils/story_actions.dart';
import '../widgets/story_card.dart';

/// Saved (bookmarked) articles tab, for offline reading.
class SavedScreen extends StatelessWidget {
  const SavedScreen({
    super.key,
    required this.savedController,
    required this.settingsController,
  });

  final SavedStoriesController savedController;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Articles',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: AnimatedBuilder(
        animation: savedController,
        builder: (context, _) {
          final saved = savedController.saved;
          if (saved.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Tap "Save" on a headline to read it later, even offline.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: saved.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final story = saved[index];
              return StoryCard(
                story: story,
                isSaved: true,
                onTap: () => openStoryLink(
                  story,
                  openInApp: settingsController.openInApp,
                ),
                onToggleSave: () => savedController.toggle(story),
                onShare: () => shareStory(story),
              );
            },
          );
        },
      ),
    );
  }
}
