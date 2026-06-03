import '../../../core/network/api_client.dart';
import '../../models/transaction_model.dart';

class RemoteTransactionDataSource {
  RemoteTransactionDataSource(this._client);
  final ApiClient _client;

  Future<List<TransactionModel>> fetchAll(String userId, {String? month}) async {
    final data = await _client.get(
      '/transactions',
      query: month != null ? {'month': month} : null,
    );
    final list = data as List<dynamic>;
    return list
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>, userId))
        .toList();
  }

  Future<TransactionModel> create(TransactionModel model) async {
    final data = await _client.post('/transactions', body: model.toApiBody());
    return TransactionModel.fromJson(data as Map<String, dynamic>, model.userId);
  }

  Future<TransactionModel> update(TransactionModel model) async {
    final data = await _client.put(
      '/transactions/${model.id}',
      body: model.toApiBody(),
    );
    return TransactionModel.fromJson(data as Map<String, dynamic>, model.userId);
  }

  Future<void> deleteRemote(String id) async {
    await _client.delete('/transactions/$id');
  }

  Future<Map<String, dynamic>> summary({String? month}) async {
    return await _client.get(
          '/transactions/summary',
          query: month != null ? {'month': month} : null,
        )
        as Map<String, dynamic>;
  }
}
