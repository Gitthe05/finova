import '../../../core/utils/view_status.dart';
import '../../../domain/entities/news_item.dart';

class NewsState {
  const NewsState({
    this.status = ViewStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final ViewStatus status;
  final List<NewsItem> items;
  final String? errorMessage;

  NewsState copyWith({
    ViewStatus? status,
    List<NewsItem>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NewsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
