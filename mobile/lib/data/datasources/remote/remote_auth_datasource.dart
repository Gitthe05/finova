import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

class RemoteAuthDataSource {
  RemoteAuthDataSource(this._client);
  final ApiClient _client;

  Future<({UserModel user, String token})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _client.post(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
      auth: false,
    ) as Map<String, dynamic>;
    return _parseAuth(data);
  }

  Future<({UserModel user, String token})> login({
    required String email,
    required String password,
  }) async {
    final data = await _client.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
    ) as Map<String, dynamic>;
    return _parseAuth(data);
  }

  ({UserModel user, String token}) _parseAuth(Map<String, dynamic> data) {
    final userJson = data['user'] as Map<String, dynamic>;
    final user = UserModel(
      id: userJson['id'] as String,
      name: userJson['name'] as String,
      email: userJson['email'] as String,
      passwordHash: '',
      createdAt: DateTime.parse(userJson['createdAt'] as String),
    );
    return (user: user, token: data['accessToken'] as String);
  }
}
