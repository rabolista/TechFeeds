import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/story.dart';

/// Talks to the public Hacker News (Algolia) search API — no backend/API key
/// required. Mirrors the pagination behavior of the original app.
class HnService {
  const HnService();

  static const _baseUrl = 'https://hn.algolia.com/api/v1/search_by_date';

  Future<List<Story>> fetchStories({required int page}) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'tags': 'story',
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
}

class HnServiceException implements Exception {
  HnServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
