import '../../entities/news_item.dart';
import '../../repositories/news_repository.dart';

class GetNewsUseCase {
  GetNewsUseCase(this._repository);
  final NewsRepository _repository;

  Future<List<NewsItem>> call() => _repository.getFinancialNews();
}
