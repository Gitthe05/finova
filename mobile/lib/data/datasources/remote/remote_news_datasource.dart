import '../../../core/network/api_client.dart';
import '../../models/news_model.dart';

class RemoteNewsDataSource {
  RemoteNewsDataSource(this._client);
  final ApiClient _client;

  Future<List<NewsModel>> fetch() async {
    final data =
        await _client.get('/financial-news', auth: false) as Map<String, dynamic>;
    return (data['items'] as List<dynamic>? ?? [])
        .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
