import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class GetSessionUseCase {
  GetSessionUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserEntity?> call() => _repository.getCurrentUser();
  Future<bool> isLoggedIn() => _repository.isLoggedIn();
}
