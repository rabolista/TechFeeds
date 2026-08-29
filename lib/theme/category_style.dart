import 'package:flutter/material.dart';

import '../models/story_category.dart';

/// Maps each [StoryCategory] to a representative color and icon so the UI
/// can visually distinguish categories at a glance.
class CategoryStyle {
  const CategoryStyle._();

  static Color colorFor(StoryCategory category) {
    switch (category) {
      case StoryCategory.all:
        return const Color(0xFF0B72B9);
      case StoryCategory.apple:
        return const Color(0xFF4A4A4A);
      case StoryCategory.android:
        return const Color(0xFF3DDC84);
      case StoryCategory.ai:
        return const Color(0xFF7B4FA0);
      case StoryCategory.security:
        return const Color(0xFFD9822B);
    }
  }

  static IconData iconFor(StoryCategory category) {
    switch (category) {
      case StoryCategory.all:
        return Icons.dynamic_feed_rounded;
      case StoryCategory.apple:
        return Icons.phone_iphone_rounded;
      case StoryCategory.android:
        return Icons.android_rounded;
      case StoryCategory.ai:
        return Icons.auto_awesome_rounded;
      case StoryCategory.security:
        return Icons.shield_rounded;
    }
  }
}
