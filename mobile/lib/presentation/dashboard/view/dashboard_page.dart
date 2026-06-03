import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../domain/entities/financial_summary.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/shell_layout.dart';
import '../../../core/utils/view_status.dart';
import '../../../shared/widgets/balance_card.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/summary_card.dart';
import '../../../shared/widgets/transaction_tile.dart';
import '../viewmodel/dashboard_state.dart';
import '../viewmodel/dashboard_view_model.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dashboardViewModelProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider);
    final vm = ref.read(dashboardViewModelProvider.notifier);

    return ColoredBox(
      color: context.surfaces.screenTint,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: vm.load,
          child: _content(state, vm),
        ),
      ),
    );
  }

  Widget _content(DashboardState state, DashboardViewModel vm) {
    final padding = shellListPadding(context);

    if (state.status == ViewStatus.loading) {
      return LoadingSkeleton(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: padding,
          children: const [
            SizedBox(height: 120, child: Card(child: SizedBox.expand())),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Card(child: SizedBox(height: 88))),
                SizedBox(width: 12),
                Expanded(child: Card(child: SizedBox(height: 88))),
              ],
            ),
          ],
        ),
      );
    }
    if (state.status == ViewStatus.error) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [
          ErrorState(message: state.errorMessage ?? 'Erro', onRetry: vm.load),
        ],
      );
    }
    final summary = state.summary;
    if (summary == null) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        children: const [
          EmptyState(title: 'Sem dados no momento'),
        ],
      );
    }

    if (state.recent.isEmpty) {
      return _emptyDashboardLayout(state, summary, padding);
    }

    return ListView(
      padding: padding,
      children: [
        ..._dashboardTopSections(state, summary),
        _sectionTitle(context, 'Últimas movimentações'),
        const SizedBox(height: AppTokens.spaceSm),
        PremiumCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < state.recent.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                TransactionTile(transaction: state.recent[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppTokens.spaceMd),
        _sectionTitle(context, 'Insights'),
        const SizedBox(height: AppTokens.spaceSm),
        _insightsCard(context),
      ],
    );
  }

  Widget _emptyDashboardLayout(
    DashboardState state,
    FinancialSummary summary,
    EdgeInsets padding,
  ) {
    final bottomInset = shellBottomInset(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                padding.left,
                padding.top,
                padding.right,
                bottomInset,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._dashboardTopSections(state, summary, compact: true),
                  const SizedBox(height: AppTokens.spaceSm),
                  _sectionTitle(context, 'Últimas movimentações'),
                  const SizedBox(height: AppTokens.spaceSm),
                  Expanded(
                    child: PremiumCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.spaceMd,
                        vertical: AppTokens.spaceSm,
                      ),
                      child: const Center(
                        child: EmptyState(
                          title: 'Nenhuma movimentação ainda',
                          subtitle: 'Adicione uma transação na aba Transações',
                          compact: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _dashboardTopSections(
    DashboardState state,
    FinancialSummary summary, {
    bool compact = false,
  }) {
    final gap = compact ? AppTokens.spaceSm : AppTokens.spaceMd;
    return [
      Row(
        children: [
          const Expanded(child: BrandLogo(compact: true)),
          IconButton(
            onPressed: () => ref.read(dashboardViewModelProvider.notifier).load(),
            icon: const Icon(Symbols.refresh_rounded),
            style: IconButton.styleFrom(
              backgroundColor: context.surfaces.inputFill,
              foregroundColor: context.surfaces.textPrimary,
              side: BorderSide(color: context.surfaces.border),
            ),
          ),
        ],
      ),
      SizedBox(height: gap),
      BalanceCard(balance: summary.balance)
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.08, end: 0),
      SizedBox(height: gap),
      Row(
        children: [
          Expanded(
            child: SummaryCard(
              title: 'Receitas',
              value: summary.income,
              icon: Symbols.arrow_downward_alt,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'Despesas',
              value: summary.expense,
              icon: Symbols.arrow_upward_alt,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
      SizedBox(height: gap),
      PremiumCard(
        padding: EdgeInsets.all(compact ? AppTokens.spaceSm : AppTokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumo do mês', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              '${summary.count} transações · ${AppFormatters.monthYear.format(DateTime.now())}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: compact ? AppTokens.spaceSm : AppTokens.spaceMd),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.goalProgress,
                minHeight: 8,
                backgroundColor: context.surfaces.border,
                color: context.accentHighlight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Meta: ${(state.goalProgress * 100).toStringAsFixed(0)}% de ${AppFormatters.money(AppConstants.financialGoalDefault)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.surfaces.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _insightsCard(BuildContext context) {
    return PremiumCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Symbols.lightbulb, color: AppColors.teal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dica financeira', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  'Separe 20% da renda para reserva antes de planejar gastos variáveis.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
