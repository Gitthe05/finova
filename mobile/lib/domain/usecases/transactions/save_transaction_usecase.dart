import '../../entities/transaction_entity.dart';
import '../../repositories/transaction_repository.dart';

class SaveTransactionUseCase {
  SaveTransactionUseCase(this._repository);
  final TransactionRepository _repository;

  Future<TransactionEntity> create(TransactionEntity tx) =>
      _repository.create(tx);

  Future<TransactionEntity> update(TransactionEntity tx) =>
      _repository.update(tx);
}
