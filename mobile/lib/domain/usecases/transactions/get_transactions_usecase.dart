import '../../entities/transaction_entity.dart';
import '../../entities/transaction_type.dart';
import '../../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  GetTransactionsUseCase(this._repository);
  final TransactionRepository _repository;

  Future<List<TransactionEntity>> call({
    TransactionType? type,
    String? category,
    DateTime? month,
    String? search,
  }) {
    return _repository.getTransactions(
      type: type,
      category: category,
      month: month,
      search: search,
    );
  }
}
