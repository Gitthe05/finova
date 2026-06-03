import '../../repositories/category_repository.dart';

class DeleteCategoryUseCase {
  DeleteCategoryUseCase(this._repository);
  final CategoryRepository _repository;

  Future<void> call(String id) => _repository.deleteCategory(id);
}
