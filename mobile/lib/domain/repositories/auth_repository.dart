import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  });
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> logout();
}
