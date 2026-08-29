/// A single Hacker News story mapped from the Algolia search API.
class Story {
  const Story({
    required this.id,
    required this.title,
    required this.url,
    required this.domain,
    required this.createdAtUtc,
    required this.points,
    required this.numComments,
    required this.author,
  });

  final String id;
  final String title;
  final String url;
  final String domain;
  final DateTime createdAtUtc;
  final int points;
  final int numComments;
  final String author;

  factory Story.fromAlgolia(Map<String, dynamic> item) {
    final url = (item['url'] ?? item['story_url'] ?? '') as String;
    final createdAtI = item['created_at_i'];
    final createdAtUtc = createdAtI is int
        ? DateTime.fromMillisecondsSinceEpoch(createdAtI * 1000, isUtc: true)
        : DateTime.now().toUtc();

    return Story(
      id: (item['objectID'] ?? '').toString(),
      title:
          (item['title'] ?? item['story_title'] ?? '(untitled)') as String,
      url: url,
      domain: _domainFrom(url),
      createdAtUtc: createdAtUtc,
      points: (item['points'] as int?) ?? 0,
      numComments: (item['num_comments'] as int?) ?? 0,
      author: (item['author'] ?? '') as String,
    );
  }

  static String _domainFrom(String url) {
    if (url.isEmpty) return 'news.ycombinator.com';
    final match = RegExp(r'^https?://([^/]+)', caseSensitive: false)
        .firstMatch(url);
    return match?.group(1) ?? 'news.ycombinator.com';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'domain': domain,
        'createdAtUtc': createdAtUtc.toIso8601String(),
        'points': points,
        'numComments': numComments,
        'author': author,
      };

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String,
        title: json['title'] as String,
        url: json['url'] as String,
        domain: json['domain'] as String,
        createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
        points: json['points'] as int? ?? 0,
        numComments: json['numComments'] as int? ?? 0,
        author: json['author'] as String? ?? '',
      );
}
