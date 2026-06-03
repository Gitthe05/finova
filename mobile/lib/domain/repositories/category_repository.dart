import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Stream<List<CategoryEntity>> watchCategories();
  Future<List<CategoryEntity>> getCategories();
  Future<void> saveCategory({
    String? id,
    required String name,
    required String type,
    String iconKey = 'category',
  });
  Future<void> deleteCategory(String id);
  Future<int> countTransactionsUsing(String name, String type);
}
