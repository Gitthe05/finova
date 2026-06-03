import '../../../core/utils/view_status.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/transaction_type.dart';

class TransactionsState {
  const TransactionsState({
    this.status = ViewStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.filterType,
    this.filterCategory,
    this.filterMonth,
    this.searchQuery = '',
  });

  final ViewStatus status;
  final List<TransactionEntity> items;
  final String? errorMessage;
  final TransactionType? filterType;
  final String? filterCategory;
  final DateTime? filterMonth;
  final String searchQuery;

  TransactionsState copyWith({
    ViewStatus? status,
    List<TransactionEntity>? items,
    String? errorMessage,
    TransactionType? filterType,
    String? filterCategory,
    DateTime? filterMonth,
    String? searchQuery,
    bool clearFilterType = false,
    bool clearFilterCategory = false,
    bool clearFilterMonth = false,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
      filterCategory: clearFilterCategory ? null : (filterCategory ?? this.filterCategory),
      filterMonth: clearFilterMonth ? null : (filterMonth ?? this.filterMonth),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
