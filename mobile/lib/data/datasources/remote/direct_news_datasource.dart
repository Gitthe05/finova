import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/news_api_config.dart';
import '../../../core/utils/news_article_text.dart';
import '../../models/news_model.dart';

class DirectNewsDataSource {
  DirectNewsDataSource({
    String? apiUrl,
    String? apiKey,
  })  : _apiUrl = apiUrl ?? NewsApiConfig.url,
        _apiKey = apiKey ?? NewsApiConfig.apiKey;

  final String _apiUrl;
  final String _apiKey;

  bool get isConfigured => _apiKey.isNotEmpty;

  static const _headlinesFallbackUrl =
      'https://newsapi.org/v2/top-headlines?country=br&category=business&pageSize=15';

  Future<List<NewsModel>> fetch() async {
    if (!isConfigured) return [];

    final fromEverything = await _request(_apiUrl);
    if (fromEverything.isNotEmpty) return fromEverything;

    return _request(_headlinesFallbackUrl);
  }

  Future<List<NewsModel>> _request(String apiUrl) async {
    try {
      final base = Uri.parse(apiUrl);
      final uri = base.replace(
        queryParameters: {...base.queryParameters, 'apiKey': _apiKey},
      );

      final res = await http
          .get(
            uri,
            headers: const {
              'Accept': 'application/json',
              'User-Agent': 'Finova/1.0',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (res.body.isEmpty) return [];

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode < 200 ||
          res.statusCode >= 300 ||
          data['status'] == 'error') {
        return [];
      }

      return _parseArticles(data['articles'] as List<dynamic>? ?? []);
    } catch (_) {
      return [];
    }
  }

  List<NewsModel> _parseArticles(List<dynamic> articles) {
    final items = <NewsModel>[];
    for (var i = 0; i < articles.length && items.length < 15; i++) {
      final a = articles[i] as Map<String, dynamic>;
      final title = a['title'] as String?;
      final url = a['url'] as String?;
      if (title == null || title.isEmpty || url == null || url.isEmpty) continue;
      final source = a['source'] as Map<String, dynamic>?;
      items.add(
        NewsModel(
          id: 'newsapi-$i',
          title: title,
          description: pickNewsArticleBody(
            a['description'] as String?,
            a['content'] as String?,
          ),
          source: source?['name'] as String? ?? 'Notícias',
          url: url,
          publishedAt:
              a['publishedAt'] as String? ?? DateTime.now().toIso8601String(),
          imageUrl: a['urlToImage'] as String?,
        ),
      );
    }
    return items;
  }
}
