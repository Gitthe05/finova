import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/view_status.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../domain/usecases/transactions/delete_transaction_usecase.dart';
import '../../../domain/usecases/transactions/get_transactions_usecase.dart';
import '../../../domain/usecases/transactions/save_transaction_usecase.dart';
import '../../../domain/usecases/transactions/sync_transactions_usecase.dart';
import 'transactions_state.dart';

final transactionsViewModelProvider =
    StateNotifierProvider<TransactionsViewModel, TransactionsState>((ref) {
  return TransactionsViewModel(
    getTransactions: ref.watch(getTransactionsUseCaseProvider),
    saveTransaction: ref.watch(saveTransactionUseCaseProvider),
    deleteTransaction: ref.watch(deleteTransactionUseCaseProvider),
    syncTransactions: ref.watch(syncTransactionsUseCaseProvider),
    userId: ref.watch(sessionStorageProvider).getUserId,
  );
});

class TransactionsViewModel extends StateNotifier<TransactionsState> {
  TransactionsViewModel({
    required GetTransactionsUseCase getTransactions,
    required SaveTransactionUseCase saveTransaction,
    required DeleteTransactionUseCase deleteTransaction,
    required SyncTransactionsUseCase syncTransactions,
    required Future<String?> Function() userId,
  })  : _getTransactions = getTransactions,
        _saveTransaction = saveTransaction,
        _deleteTransaction = deleteTransaction,
        _syncTransactions = syncTransactions,
        _userId = userId,
        super(const TransactionsState());

  final GetTransactionsUseCase _getTransactions;
  final SaveTransactionUseCase _saveTransaction;
  final DeleteTransactionUseCase _deleteTransaction;
  final SyncTransactionsUseCase _syncTransactions;
  final Future<String?> Function() _userId;
  final _uuid = const Uuid();

  Future<void> load() async {
    state = state.copyWith(status: ViewStatus.loading);
    try {
      await _syncTransactions.call();
      final items = await _getTransactions(
        type: state.filterType,
        category: state.filterCategory,
        month: state.filterMonth,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      state = state.copyWith(
        status: items.isEmpty ? ViewStatus.empty : ViewStatus.success,
        items: items,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void setFilterType(TransactionType? type) {
    state = state.copyWith(
      filterType: type,
      clearFilterType: type == null,
    );
    load();
  }

  void setFilterCategory(String? category) {
    state = state.copyWith(
      filterCategory: category,
      clearFilterCategory: category == null,
    );
    load();
  }

  void setFilterMonth(DateTime? month) {
    state = state.copyWith(
      filterMonth: month,
      clearFilterMonth: month == null,
    );
    load();
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    load();
  }

  Future<bool> save({
    String? id,
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    required DateTime date,
    String? description,
  }) async {
    final uid = await _userId();
    if (uid == null) return false;
    final now = DateTime.now();
    final entity = TransactionEntity(
      id: id ?? _uuid.v4(),
      userId: uid,
      title: title.trim(),
      amount: amount,
      type: type,
      category: category,
      description: description?.trim(),
      date: date,
      createdAt: now,
      updatedAt: now,
    );
    try {
      if (id == null) {
        await _saveTransaction.create(entity);
      } else {
        await _saveTransaction.update(entity);
      }
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> remove(String id) async {
    try {
      await _deleteTransaction.call(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}
