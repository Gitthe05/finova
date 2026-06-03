import '../../../core/utils/view_status.dart';
import '../../../domain/entities/financial_summary.dart';
import '../../../domain/entities/transaction_entity.dart';

class DashboardState {
  const DashboardState({
    this.status = ViewStatus.initial,
    this.summary,
    this.recent = const [],
    this.errorMessage,
    this.goalProgress = 0,
  });

  final ViewStatus status;
  final FinancialSummary? summary;
  final List<TransactionEntity> recent;
  final String? errorMessage;
  final double goalProgress;

  DashboardState copyWith({
    ViewStatus? status,
    FinancialSummary? summary,
    List<TransactionEntity>? recent,
    String? errorMessage,
    double? goalProgress,
  }) {
    return DashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      recent: recent ?? this.recent,
      errorMessage: errorMessage,
      goalProgress: goalProgress ?? this.goalProgress,
    );
  }
}
