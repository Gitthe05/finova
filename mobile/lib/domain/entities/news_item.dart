import 'package:equatable/equatable.dart';

class NewsItem extends Equatable {
  const NewsItem({
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

  @override
  List<Object?> get props => [id, title, source, url];
}
