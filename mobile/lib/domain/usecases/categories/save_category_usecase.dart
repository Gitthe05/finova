import '../../repositories/category_repository.dart';

class SaveCategoryUseCase {
  SaveCategoryUseCase(this._repository);
  final CategoryRepository _repository;

  Future<void> call({
    String? id,
    required String name,
    required String type,
    String iconKey = 'category',
  }) =>
      _repository.saveCategory(
        id: id,
        name: name,
        type: type,
        iconKey: iconKey,
      );
}
