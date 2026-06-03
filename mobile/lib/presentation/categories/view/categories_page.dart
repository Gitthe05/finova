import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/utils/category_utils.dart';
import '../../../core/utils/shell_layout.dart';
import '../../../core/utils/view_status.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/brand_fab.dart';
import '../../../shared/widgets/premium_card.dart';
import '../view/category_form_bottom_sheet.dart';
import '../viewmodel/categories_state.dart';
import '../viewmodel/categories_view_model.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  Future<void> _openForm(BuildContext context, WidgetRef ref, {CategoryEntity? category}) async {
    final result = await showAppBottomSheet<Map<String, dynamic>>(
      context,
      child: CategoryFormBottomSheet(category: category),
    );
    if (result == null) return;
    final error = await ref.read(categoriesViewModelProvider.notifier).save(
          id: result['id'] as String?,
          name: result['name'] as String,
          type: result['type'] as TransactionType,
        );
    if (!context.mounted) return;
    if (error != null) {
      showAppToast(context, message: error, variant: AppToastVariant.error);
    } else {
      showAppToast(
        context,
        message: category == null ? 'Categoria criada' : 'Categoria atualizada',
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity category,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Excluir categoria?',
      message: 'Esta ação não pode ser desfeita.',
      highlight: category.name,
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    final error = await ref.read(categoriesViewModelProvider.notifier).remove(category.id);
    if (!context.mounted) return;
    if (error != null) {
      showAppToast(context, message: error, variant: AppToastVariant.error);
    } else {
      showAppToast(context, message: 'Categoria excluída');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoriesViewModelProvider);
    final surfaces = context.surfaces;
    final padding = shellListPadding(context);

    return ColoredBox(
      color: surfaces.screenTint,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          floatingActionButton: BrandFab(
            heroTag: 'fab_categories',
            onPressed: () => _openForm(context, ref),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  padding.left,
                  AppTokens.spaceSm,
                  padding.right,
                  AppTokens.spaceSm,
                ),
                child: Text(
                  'Categorias',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Expanded(child: _body(context, ref, state, padding)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    CategoriesState state,
    EdgeInsets padding,
  ) {
    if (state.status == ViewStatus.error) {
      return ListView(
        padding: padding,
        children: [
          ErrorState(
            message: state.errorMessage ?? 'Erro ao carregar categorias',
            onRetry: () {},
          ),
        ],
      );
    }

    final items = state.items;
    if (items.isEmpty && state.status != ViewStatus.success) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    final income = items.forType(TransactionType.income);
    final expense = items.forType(TransactionType.expense);

    if (income.isEmpty && expense.isEmpty) {
      return ListView(
        padding: padding,
        children: const [
          EmptyState(
            title: 'Nenhuma categoria',
            subtitle: 'Toque no + para adicionar',
          ),
        ],
      );
    }

    return ListView(
      padding: padding,
      children: [
        if (income.isNotEmpty) ...[
          _sectionTitle(context, 'Receitas'),
          const SizedBox(height: 8),
          ...income.asMap().entries.map(
                (e) => _CategoryTile(
                  category: e.value,
                  onTap: () => _openForm(context, ref, category: e.value),
                  onDelete: () => _confirmDelete(context, ref, e.value),
                ).animate().fadeIn(delay: (30 * e.key).ms),
              ),
          const SizedBox(height: 24),
        ],
        if (expense.isNotEmpty) ...[
          _sectionTitle(context, 'Despesas'),
          const SizedBox(height: 8),
          ...expense.asMap().entries.map(
                (e) => _CategoryTile(
                  category: e.value,
                  onTap: () => _openForm(context, ref, category: e.value),
                  onDelete: () => _confirmDelete(context, ref, e.value),
                ).animate().fadeIn(delay: (30 * e.key).ms),
              ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  final CategoryEntity category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color =
        category.type == TransactionType.income ? AppColors.success : AppColors.danger;
    final icon = categoryIconForKey(category.iconKey);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PremiumCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      category.type.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.surfaces.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Symbols.delete_outline, size: 22),
                color: AppColors.danger.withValues(alpha: 0.85),
                tooltip: 'Excluir',
              ),
              Icon(
                Symbols.chevron_right,
                color: context.surfaces.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
