import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../core/utils/view_status.dart';
import '../../../domain/usecases/dashboard/get_summary_usecase.dart';
import '../../../domain/usecases/transactions/get_transactions_usecase.dart';
import '../../../domain/usecases/transactions/sync_transactions_usecase.dart';
import 'dashboard_state.dart';

final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  return DashboardViewModel(
    getSummary: ref.watch(getSummaryUseCaseProvider),
    getTransactions: ref.watch(getTransactionsUseCaseProvider),
    syncTransactions: ref.watch(syncTransactionsUseCaseProvider),
  );
});

class DashboardViewModel extends StateNotifier<DashboardState> {
  DashboardViewModel({
    required GetSummaryUseCase getSummary,
    required GetTransactionsUseCase getTransactions,
    required SyncTransactionsUseCase syncTransactions,
  })  : _getSummary = getSummary,
        _getTransactions = getTransactions,
        _syncTransactions = syncTransactions,
        super(const DashboardState());

  final GetSummaryUseCase _getSummary;
  final GetTransactionsUseCase _getTransactions;
  final SyncTransactionsUseCase _syncTransactions;

  Future<void> load() async {
    state = state.copyWith(status: ViewStatus.loading);
    try {
      await _syncTransactions.call();
      final now = DateTime.now();
      final summary = await _getSummary(month: DateTime(now.year, now.month));
      final month = DateTime(now.year, now.month);
      final all = await _getTransactions(month: month);
      final sorted = List.of(all)..sort((a, b) => b.date.compareTo(a.date));
      final recent = sorted.take(5).toList();
      final goalProgress = (summary.balance / AppConstants.financialGoalDefault)
          .clamp(0.0, 1.0);
      state = DashboardState(
        status: ViewStatus.success,
        summary: summary,
        recent: recent,
        goalProgress: goalProgress,
      );
    } catch (e) {
      state = state.copyWith(
        status: ViewStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
