import '../../domain/entities/transaction_type.dart';
import 'default_categories.dart';

@Deprecated('Use categoriesStreamProvider ou CategoryRepository')
class AppCategories {
  static List<String> get income => DefaultCategories.seeds
      .where((s) => s.type == TransactionType.income)
      .map((s) => s.name)
      .toList();

  static List<String> get expense => DefaultCategories.seeds
      .where((s) => s.type == TransactionType.expense)
      .map((s) => s.name)
      .toList();

  static List<String> forType(TransactionType type) {
    return type == TransactionType.income ? income : expense;
  }
}
