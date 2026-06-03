import 'package:uuid/uuid.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_auth_datasource.dart';
import '../datasources/local/session_storage.dart';
import '../datasources/remote/remote_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required LocalAuthDataSource local,
    required RemoteAuthDataSource remote,
    required SessionStorage session,
  })  : _local = local,
        _remote = remote,
        _session = session;

  final LocalAuthDataSource _local;
  final RemoteAuthDataSource _remote;
  final SessionStorage _session;
  final _uuid = const Uuid();

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final id = _uuid.v4();
    try {
      final result = await _remote.register(
        name: name,
        email: email,
        password: password,
      );
      await _local.registerLocal(
        name: name,
        email: email,
        password: password,
        id: result.user.id,
      );
      await _session.saveSession(
        token: result.token,
        userId: result.user.id,
        name: result.user.name,
        email: result.user.email,
      );
      return result.user.toEntity();
    } catch (_) {
      final local = await _local.registerLocal(
        name: name,
        email: email,
        password: password,
        id: id,
      );
      await _session.saveSession(
        token: 'local_$id',
        userId: local.id,
        name: local.name,
        email: local.email,
      );
      return local.toEntity();
    }
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remote.login(email: email, password: password);
      final existing = await _local.findByEmail(email);
      if (existing == null) {
        await _local.registerLocal(
          name: result.user.name,
          email: email,
          password: password,
          id: result.user.id,
        );
      }
      await _session.saveSession(
        token: result.token,
        userId: result.user.id,
        name: result.user.name,
        email: result.user.email,
      );
      return result.user.toEntity();
    } catch (_) {
      final local = await _local.loginLocal(email, password);
      if (local == null) {
        throw Exception('Credenciais inválidas');
      }
      await _session.saveSession(
        token: 'local_${local.id}',
        userId: local.id,
        name: local.name,
        email: local.email,
      );
      return local.toEntity();
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final id = await _session.getUserId();
    final name = await _session.getUserName();
    final email = await _session.getUserEmail();
    if (id == null || name == null || email == null) return null;
    final local = await _local.findByEmail(email);
    return UserEntity(
      id: id,
      name: name,
      email: email,
      createdAt: local?.createdAt ?? DateTime.now(),
    );
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _session.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> logout() => _session.clear();
}
