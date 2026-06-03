import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../../models/news_model.dart';

class RssNewsDataSource {
  static const _feeds = <({String source, String url})>[
    (source: 'G1 Economia', url: 'https://g1.globo.com/economia/rss/g1-economia.xml'),
    (source: 'InfoMoney', url: 'https://www.infomoney.com.br/feed/'),
  ];

  Future<List<NewsModel>> fetch() async {
    for (final feed in _feeds) {
      try {
        final items = await _fetchFeed(feed.source, feed.url);
        if (items.isNotEmpty) return items.take(15).toList();
      } catch (_) {}
    }
    return [];
  }

  Future<List<NewsModel>> _fetchFeed(String source, String url) async {
    final res = await http
        .get(
          Uri.parse(url),
          headers: const {'User-Agent': 'Finova/1.0'},
        )
        .timeout(const Duration(seconds: 12));

    if (res.statusCode < 200 || res.statusCode >= 300) return [];

    final doc = XmlDocument.parse(res.body);
    final items = <NewsModel>[];

    for (final node in doc.findAllElements('item')) {
      final title = _text(node, 'title');
      final link = _text(node, 'link');
      if (title.isEmpty || link.isEmpty) continue;

      items.add(
        NewsModel(
          id: 'rss-${items.length}',
          title: _stripHtml(title),
          description: _stripHtml(
            _text(node, 'description').isNotEmpty
                ? _text(node, 'description')
                : _text(node, 'summary'),
          ),
          source: source,
          url: link,
          publishedAt: _parseDate(_text(node, 'pubDate')) ??
              DateTime.now().toIso8601String(),
        ),
      );
      if (items.length >= 15) break;
    }

    if (items.isEmpty) {
      for (final entry in doc.findAllElements('entry')) {
        final title = _text(entry, 'title');
        var link = _text(entry, 'link');
        if (link.isEmpty) {
          final href = entry.getElement('link')?.getAttribute('href');
          if (href != null) link = href;
        }
        if (title.isEmpty || link.isEmpty) continue;

        items.add(
          NewsModel(
            id: 'rss-${items.length}',
            title: _stripHtml(title),
            description: _stripHtml(_text(entry, 'summary')),
            source: source,
            url: link,
            publishedAt: _parseDate(_text(entry, 'updated')) ??
                DateTime.now().toIso8601String(),
          ),
        );
        if (items.length >= 15) break;
      }
    }

    return items;
  }

  String _text(XmlElement parent, String tag) {
    final el = parent.getElement(tag);
    return el?.innerText.trim() ?? '';
  }

  String _stripHtml(String raw) {
    return raw
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _parseDate(String raw) {
    if (raw.isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return parsed.toIso8601String();
    return null;
  }
}
