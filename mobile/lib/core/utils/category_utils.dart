import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_type.dart';

extension CategoryListX on List<CategoryEntity> {
  List<CategoryEntity> forType(TransactionType type) =>
      where((c) => c.type == type).toList();

  List<String> namesFor(TransactionType type) =>
      forType(type).map((c) => c.name).toList();

  String? firstNameFor(TransactionType type) {
    final list = namesFor(type);
    return list.isEmpty ? null : list.first;
  }
}
