import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/comment.dart';
import '../models/story.dart';

/// Which Hacker News ranking to pull stories from.
enum FeedMode { newest, top }

/// Talks to the public Hacker News (Algolia) search API — no backend/API key
/// required. Mirrors the pagination behavior of the original app.
class HnService {
  const HnService();

  static const _searchByDateUrl = 'https://hn.algolia.com/api/v1/search_by_date';
  static const _searchUrl = 'https://hn.algolia.com/api/v1/search';
  static const _itemUrl = 'https://hn.algolia.com/api/v1/items';

  Future<List<Story>> fetchStories({
    required int page,
    FeedMode mode = FeedMode.newest,
  }) async {
    final uri = mode == FeedMode.newest
        ? Uri.parse(_searchByDateUrl).replace(queryParameters: {
            'tags': 'story',
            'hitsPerPage': '20',
            'page': '$page',
          })
        : Uri.parse(_searchUrl).replace(queryParameters: {
            'tags': 'front_page',
            'hitsPerPage': '20',
            'page': '$page',
          });

    final response = await http
        .get(uri)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw HnServiceException('Request failed (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final hits = (decoded['hits'] as List<dynamic>?) ?? const [];
    return hits
        .cast<Map<String, dynamic>>()
        .map(Story.fromAlgolia)
        .toList(growable: false);
  }

  /// Fetches the full comment tree for a story.
  Future<List<Comment>> fetchComments(String storyId) async {
    final uri = Uri.parse('$_itemUrl/$storyId');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw HnServiceException('Request failed (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final children = (decoded['children'] as List<dynamic>?) ?? const [];
    return children
        .cast<Map<String, dynamic>>()
        .map((c) => Comment.fromAlgolia(c))
        .whereType<Comment>()
        .toList();
  }
}


class HnServiceException implements Exception {
  HnServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
