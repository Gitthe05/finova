import '../../domain/entities/news_item.dart';

class NewsModel {
  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.source,
    required this.url,
    required this.publishedAt,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final String source;
  final String url;
  final String publishedAt;
  final String? imageUrl;

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      source: json['source'] as String? ?? 'Notícias',
      url: json['url'] as String? ?? '',
      publishedAt: json['publishedAt'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  NewsItem toEntity() => NewsItem(
        id: id,
        title: title,
        description: description,
        source: source,
        url: url,
        publishedAt: publishedAt,
        imageUrl: imageUrl,
      );
}
