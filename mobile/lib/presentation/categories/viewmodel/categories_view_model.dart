import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/view_status.dart';
import '../../../data/repositories/category_repository_impl.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/usecases/categories/delete_category_usecase.dart';
import '../../../domain/usecases/categories/save_category_usecase.dart';
import 'categories_state.dart';

final categoriesViewModelProvider =
    StateNotifierProvider<CategoriesViewModel, CategoriesState>((ref) {
  return CategoriesViewModel(
    saveCategory: ref.watch(saveCategoryUseCaseProvider),
    deleteCategory: ref.watch(deleteCategoryUseCaseProvider),
    watchCategories: () => ref.watch(categoryRepositoryProvider).watchCategories(),
  );
});

class CategoriesViewModel extends StateNotifier<CategoriesState> {
  CategoriesViewModel({
    required SaveCategoryUseCase saveCategory,
    required DeleteCategoryUseCase deleteCategory,
    required Stream<List<CategoryEntity>> Function() watchCategories,
  })  : _saveCategory = saveCategory,
        _deleteCategory = deleteCategory,
        _watchCategories = watchCategories,
        super(const CategoriesState()) {
    _subscribe();
  }

  final SaveCategoryUseCase _saveCategory;
  final DeleteCategoryUseCase _deleteCategory;
  final Stream<List<CategoryEntity>> Function() _watchCategories;

  void _subscribe() {
    _watchCategories().listen(
      (items) {
        state = CategoriesState(
          status: items.isEmpty ? ViewStatus.empty : ViewStatus.success,
          items: items,
        );
      },
      onError: (e) {
        state = state.copyWith(
          status: ViewStatus.error,
          errorMessage: e.toString(),
        );
      },
    );
  }

  Future<String?> save({
    String? id,
    required String name,
    required TransactionType type,
  }) async {
    try {
      await _saveCategory(
        id: id,
        name: name,
        type: type.name,
      );
      return null;
    } on CategoryRepositoryException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> remove(String id) async {
    try {
      await _deleteCategory(id);
      return null;
    } on CategoryRepositoryException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
