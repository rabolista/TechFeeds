/// Tech topics used to filter the Hacker News feed, matching the keyword
/// based categorization from the original Tech and Feeds app.
enum StoryCategory { all, apple, android, ai, security }

extension StoryCategoryX on StoryCategory {
  String get label {
    switch (this) {
      case StoryCategory.all:
        return 'All';
      case StoryCategory.apple:
        return 'Apple';
      case StoryCategory.android:
        return 'Android';
      case StoryCategory.ai:
        return 'AI';
      case StoryCategory.security:
        return 'Security';
    }
  }

  /// Keywords matched (case-insensitively) against a story title to decide
  /// whether it belongs to this category.
  List<String> get keywords {
    switch (this) {
      case StoryCategory.all:
        return const [];
      case StoryCategory.apple:
        return const ['apple', 'iphone', 'ios', 'ipad', 'macos', 'swift'];
      case StoryCategory.android:
        return const ['android', 'pixel', 'google play'];
      case StoryCategory.ai:
        return const ['ai', 'machine learning', 'llm', 'gpt', 'openai', 'neural'];
      case StoryCategory.security:
        return const ['security', 'breach', 'vulnerab', 'hack', 'exploit', 'privacy'];
    }
  }

  bool matches(String title) {
    if (this == StoryCategory.all) return true;
    final lower = title.toLowerCase();
    return keywords.any((keyword) => lower.contains(keyword));
  }
}
