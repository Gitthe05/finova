import '../../../core/utils/view_status.dart';
import '../../../domain/entities/category_entity.dart';

class CategoriesState {
  const CategoriesState({
    this.status = ViewStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  final ViewStatus status;
  final List<CategoryEntity> items;
  final String? errorMessage;

  CategoriesState copyWith({
    ViewStatus? status,
    List<CategoryEntity>? items,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
