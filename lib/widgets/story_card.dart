import 'package:flutter/material.dart';

import '../models/story.dart';
import '../utils/date_formatting.dart';

/// A news story card matching the Global Climate News article card style:
/// domain + timestamp meta row, bold title, and a "Read article" CTA, with
/// save/share actions.
class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.story,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSave,
    required this.onShare,
  });

  final Story story;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      story.domain,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('•', style: theme.textTheme.labelMedium),
                  const SizedBox(width: 6),
                  Text(
                    timeAgo(story.createdAtUtc),
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                story.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Read article',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onToggleSave,
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 18,
                    ),
                    label: Text(isSaved ? 'Saved' : 'Save'),
                  ),
                  TextButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
