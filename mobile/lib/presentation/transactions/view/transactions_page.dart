import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/date_picker_utils.dart';
import '../../../core/utils/shell_layout.dart';
import '../../../core/utils/view_status.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/brand_fab.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/transaction_tile.dart';
import '../view/transaction_form_bottom_sheet.dart';
import '../../dashboard/viewmodel/dashboard_view_model.dart';
import '../viewmodel/transactions_state.dart';
import '../viewmodel/transactions_view_model.dart';
import '../widgets/transaction_filters.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(transactionsViewModelProvider.notifier).load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openForm({TransactionEntity? transaction}) async {
    final result = await showAppBottomSheet<Map<String, dynamic>>(
      context,
      child: TransactionFormBottomSheet(transaction: transaction),
    );
    if (result == null || !mounted) return;
    final ok = await ref.read(transactionsViewModelProvider.notifier).save(
          id: result['id'] as String?,
          title: result['title'] as String,
          amount: result['amount'] as double,
          type: result['type'] as TransactionType,
          category: result['category'] as String,
          date: result['date'] as DateTime,
          description: result['description'] as String?,
        );
    if (ok && mounted) {
      ref.read(dashboardViewModelProvider.notifier).load();
      showAppToast(context, message: 'Transação salva');
    }
  }

  void _refreshDashboard() {
    ref.read(dashboardViewModelProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionsViewModelProvider);
    final vm = ref.read(transactionsViewModelProvider.notifier);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final categoryNames =
        categoriesAsync.valueOrNull?.map((c) => c.name).toList() ?? [];
    final padding = shellListPadding(context);

    return ColoredBox(
      color: context.surfaces.screenTint,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          floatingActionButton: BrandFab(
            heroTag: 'fab_transactions',
            onPressed: () => _openForm(),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: vm.load,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    padding.left,
                    AppTokens.spaceSm,
                    padding.right,
                    0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Transações',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.surfaces.inputFill,
                            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                            border: Border.all(color: context.surfaces.border),
                          ),
                          child: Icon(
                            Symbols.filter_list,
                            size: 22,
                            color: context.surfaces.textPrimary,
                          ),
                        ),
                        onSelected: vm.setFilterCategory,
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: '', child: Text('Todas categorias')),
                          ...categoryNames.map(
                            (c) => PopupMenuItem(value: c, child: Text(c)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(padding.left, AppTokens.spaceSm, padding.right, 0),
                  child: TextField(
                    controller: _search,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    decoration: InputDecoration(
                      hintText: 'Buscar transações...',
                      hintStyle: TextStyle(color: context.surfaces.textMuted),
                      prefixIcon: Icon(
                        Symbols.search,
                        color: context.surfaces.textMuted,
                      ),
                      filled: true,
                      fillColor: context.surfaces.inputFill,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        borderSide: BorderSide(color: context.surfaces.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        borderSide: BorderSide(color: context.surfaces.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        borderSide: BorderSide(
                          color: context.accentHighlight,
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: vm.setSearch,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceSm),
                TransactionFilters(
                  padding: EdgeInsets.symmetric(horizontal: padding.left),
                  selectedType: state.filterType,
                  onTypeChanged: vm.setFilterType,
                  selectedMonth: state.filterMonth,
                  onMonthPick: () async {
                    final now = DateTime.now();
                    final picked = await showAppDatePicker(
                      context,
                      initialDate: state.filterMonth ?? now,
                      firstDate: DateTime(2020),
                      lastDate: now,
                    );
                    if (picked != null) {
                      vm.setFilterMonth(DateTime(picked.year, picked.month));
                    }
                  },
                ),
                const SizedBox(height: AppTokens.spaceSm),
                Expanded(child: _body(state, vm, padding)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(TransactionsState state, TransactionsViewModel vm, EdgeInsets padding) {
    if (state.status == ViewStatus.loading) {
      return LoadingSkeleton(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: padding.left),
          children: const [
            PremiumCard(child: ListTile(title: Text('Carregando...'))),
            SizedBox(height: 8),
            PremiumCard(child: ListTile(title: Text('Carregando...'))),
          ],
        ),
      );
    }
    if (state.status == ViewStatus.error) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: padding.left),
        children: [
          ErrorState(message: state.errorMessage ?? 'Erro', onRetry: vm.load),
        ],
      );
    }
    if (state.status == ViewStatus.empty) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: padding.left),
        children: const [
          PremiumCard(
            child: EmptyState(
              title: 'Nenhuma transação',
              subtitle: 'Toque no + para adicionar',
              compact: true,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(padding.left, 0, padding.right, 88),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final tx = state.items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.spaceSm),
          child: PremiumCard(
            padding: EdgeInsets.zero,
            child: TransactionTile(
              transaction: tx,
              onTap: () => _openForm(transaction: tx),
              onDelete: () async {
                final ok = await showConfirmDialog(
                  context,
                  title: 'Excluir transação',
                  highlight: tx.title,
                  message: 'Esta ação não pode ser desfeita.',
                  confirmLabel: 'Excluir',
                  destructive: true,
                );
                if (ok == true) {
                  await vm.remove(tx.id);
                  _refreshDashboard();
                }
              },
            ),
          ),
        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05);
      },
    );
  }
}
