import '../../repositories/transaction_repository.dart';

class SyncTransactionsUseCase {
  SyncTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  Future<void> call() => _repository.syncWithServer();
}
