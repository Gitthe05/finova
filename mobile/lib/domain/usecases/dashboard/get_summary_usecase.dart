import '../../entities/financial_summary.dart';
import '../../repositories/transaction_repository.dart';

class GetSummaryUseCase {
  GetSummaryUseCase(this._repository);
  final TransactionRepository _repository;

  Future<FinancialSummary> call({DateTime? month}) =>
      _repository.getSummary(month: month);
}
