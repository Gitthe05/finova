import '../entities/financial_summary.dart';
import '../entities/transaction_entity.dart';
import '../entities/transaction_type.dart';

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions({
    TransactionType? type,
    String? category,
    DateTime? month,
    String? search,
  });
  Future<TransactionEntity> create(TransactionEntity transaction);
  Future<TransactionEntity> update(TransactionEntity transaction);
  Future<void> delete(String id);
  Future<FinancialSummary> getSummary({DateTime? month});
  Stream<List<TransactionEntity>> watchTransactions();

  Future<void> syncWithServer();
}
