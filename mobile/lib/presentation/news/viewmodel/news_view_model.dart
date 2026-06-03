import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/view_status.dart';
import '../../../domain/usecases/news/get_news_usecase.dart';
import 'news_state.dart';

final newsViewModelProvider =
    StateNotifierProvider<NewsViewModel, NewsState>((ref) {
  return NewsViewModel(ref.watch(getNewsUseCaseProvider));
});

class NewsViewModel extends StateNotifier<NewsState> {
  NewsViewModel(this._getNews) : super(const NewsState());

  final GetNewsUseCase _getNews;

  Future<void> load() async {
    state = state.copyWith(status: ViewStatus.loading, clearError: true);
    try {
      final items = await _getNews();
      state = NewsState(
        status: items.isEmpty ? ViewStatus.empty : ViewStatus.success,
        items: items,
      );
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
