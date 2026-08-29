/// A single Hacker News comment, recursively containing replies.
class Comment {
  const Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAtUtc,
    required this.children,
  });

  final String id;
  final String author;
  final String text;
  final DateTime createdAtUtc;
  final List<Comment> children;

  static Comment? fromAlgolia(Map<String, dynamic> json, {int depth = 0}) {
    final rawText = json['text'] as String?;
    if (rawText == null || rawText.isEmpty) return null;

    final createdAtI = json['created_at_i'];
    final createdAtUtc = createdAtI is int
        ? DateTime.fromMillisecondsSinceEpoch(createdAtI * 1000, isUtc: true)
        : DateTime.now().toUtc();

    final childrenJson = (json['children'] as List<dynamic>?) ?? const [];
    final children = depth >= 4
        ? const <Comment>[]
        : childrenJson
            .cast<Map<String, dynamic>>()
            .map((c) => Comment.fromAlgolia(c, depth: depth + 1))
            .whereType<Comment>()
            .toList();

    return Comment(
      id: (json['id'] ?? '').toString(),
      author: (json['author'] as String?) ?? '[deleted]',
      text: _stripHtml(rawText),
      createdAtUtc: createdAtUtc,
      children: children,
    );
  }

  static String _stripHtml(String html) {
    final withBreaks = html.replaceAll(
      RegExp(r'</p>|<br\s*/?>', caseSensitive: false),
      '\n\n',
    );
    final noTags = withBreaks.replaceAll(RegExp(r'<[^>]*>'), '');
    return noTags
        .replaceAll('&#x27;', "'")
        .replaceAll('&#x2F;', '/')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }
}
