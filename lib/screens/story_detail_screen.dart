import 'package:flutter/material.dart';

import '../models/story.dart';
import '../models/story_category.dart';
import '../state/saved_stories_controller.dart';
import '../state/settings_controller.dart';
import '../theme/category_style.dart';
import '../utils/date_formatting.dart';
import '../utils/story_actions.dart';
import 'comments_screen.dart';

/// Story detail — a native "reader" stop before leaving the app, matching
/// Global Climate News's ArticleDetailScreen pattern. Shown when a headline
/// is tapped; the actual external site only opens once the user taps
/// "Read full article".
class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({
    super.key,
    required this.story,
    required this.savedController,
    required this.settingsController,
  });

  final Story story;
  final SavedStoriesController savedController;
  final SettingsController settingsController;

  StoryCategory? get _category {
    for (final category in StoryCategory.values) {
      if (category != StoryCategory.all && category.matches(story.title)) {
        return category;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final category = _category;
    final accentColor = category != null
        ? CategoryStyle.colorFor(category)
        : Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: accentColor.withValues(alpha: 0.18),
                alignment: Alignment.center,
                child: Icon(
                  category != null
                      ? CategoryStyle.iconFor(category)
                      : Icons.rss_feed_rounded,
                  size: 72,
                  color: accentColor,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        category.label.toUpperCase(),
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    story.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          story.domain,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      Text(
                        timeAgo(story.createdAtUtc),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.arrow_upward_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(width: 4),
                      Text('${story.points} points'),
                      const SizedBox(width: 16),
                      Icon(Icons.mode_comment_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(width: 4),
                      Text('${story.numComments} comments'),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    'This headline links to an external site. Tap below to '
                    'read the full article, or jump straight into the '
                    'discussion.',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () => openStoryLink(
                      story,
                      openInApp: settingsController.openInApp,
                    ),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text('Read full article on ${story.domain}'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CommentsScreen(story: story),
                      ),
                    ),
                    icon: const Icon(Icons.forum_outlined),
                    label: Text('View discussion (${story.numComments})'),
                  ),
                  const SizedBox(height: 12),
                  AnimatedBuilder(
                    animation: savedController,
                    builder: (context, _) {
                      final isSaved = savedController.isSaved(story);
                      return Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => savedController.toggle(story),
                            icon: Icon(
                              isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                            ),
                            label: Text(isSaved ? 'Saved' : 'Save'),
                          ),
                          TextButton.icon(
                            onPressed: () => shareStory(story),
                            icon: const Icon(Icons.share_rounded),
                            label: const Text('Share'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Source: Hacker News (Algolia Search API)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
