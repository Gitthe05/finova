import '../../repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  DeleteTransactionUseCase(this._repository);
  final TransactionRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
