import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/utils/category_utils.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/date_picker_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../shared/widgets/app_money_field.dart';
import '../../../shared/widgets/app_selection_field.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/gradient_button.dart';

class TransactionFormBottomSheet extends ConsumerStatefulWidget {
  const TransactionFormBottomSheet({super.key, this.transaction});

  final TransactionEntity? transaction;

  @override
  ConsumerState<TransactionFormBottomSheet> createState() =>
      _TransactionFormBottomSheetState();
}

class _TransactionFormBottomSheetState extends ConsumerState<TransactionFormBottomSheet> {
  late final _title = TextEditingController(text: widget.transaction?.title ?? '');
  late final _amount = TextEditingController(
    text: widget.transaction != null
        ? AppFormatters.moneyInput(widget.transaction!.amount)
        : '',
  );
  late final _description = TextEditingController(
    text: widget.transaction?.description ?? '',
  );
  late TransactionType _type = widget.transaction?.type ?? TransactionType.expense;
  late String _category = widget.transaction?.category ?? 'Outros';
  late DateTime _date = widget.transaction?.date ?? DateTime.now();

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, {Widget? suffix}) {
    final surfaces = context.surfaces;
    final accent = context.accentHighlight;
    return InputDecoration(
      labelText: label,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: surfaces.textPrimary,
          ),
      filled: true,
      fillColor: surfaces.inputFill,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(color: surfaces.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(color: surfaces.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(color: accent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    return categoriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppTokens.space2xl),
        child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.all(AppTokens.spaceLg),
        child: Text('Não foi possível carregar categorias'),
      ),
      data: (all) => _form(context, all),
    );
  }

  Widget _form(BuildContext context, List<CategoryEntity> all) {
    final categoryNames = all.namesFor(_type);
    if (categoryNames.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppTokens.spaceLg),
        child: Text('Cadastre categorias na aba Categorias'),
      );
    }
    if (!categoryNames.contains(_category)) {
      _category = categoryNames.first;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.spaceLg,
        AppTokens.spaceSm,
        AppTokens.spaceLg,
        AppTokens.spaceLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.transaction == null ? 'Nova transação' : 'Editar transação',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          Row(
            children: [
              Expanded(
                child: _TypeOption(
                  label: 'Receita',
                  selected: _type == TransactionType.income,
                  onTap: () => setState(() {
                    _type = TransactionType.income;
                    _category = all.firstNameFor(TransactionType.income) ?? _category;
                  }),
                ),
              ),
              const SizedBox(width: AppTokens.spaceSm),
              Expanded(
                child: _TypeOption(
                  label: 'Despesa',
                  selected: _type == TransactionType.expense,
                  onTap: () => setState(() {
                    _type = TransactionType.expense;
                    _category = all.firstNameFor(TransactionType.expense) ?? _category;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMd),
          AppTextField(controller: _title, label: 'Título', hint: 'Ex: Supermercado'),
          const SizedBox(height: AppTokens.spaceMd),
          AppMoneyField(
            controller: _amount,
            label: 'Valor',
            hint: '0,00',
            prefixIcon: Symbols.payments,
          ),
          const SizedBox(height: AppTokens.spaceMd),
          AppSelectionField<String>(
            key: ValueKey('category-$_type'),
            label: 'Categoria',
            sheetTitle: 'Selecione a categoria',
            value: _category,
            items: categoryNames,
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          InkWell(
            onTap: () async {
              final picked = await showAppDatePicker(
                context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _date = picked);
            },
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            child: InputDecorator(
              decoration: _fieldDecoration('Data'),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Icon(
                    Symbols.calendar_month,
                    color: context.surfaces.textMuted,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          AppTextField(
            controller: _description,
            label: 'Descrição (opcional)',
            hint: 'Observações',
          ),
          const SizedBox(height: AppTokens.spaceLg),
          GradientButton(
            label: 'Salvar',
            onPressed: () {
              final amount = AppFormatters.parseMoney(_amount.text);
              if (_title.text.trim().isEmpty || amount == null || amount <= 0) {
                showAppToast(
                  context,
                  message: 'Preencha título e valor válidos',
                  variant: AppToastVariant.warning,
                );
                return;
              }
              Navigator.pop(context, {
                'id': widget.transaction?.id,
                'title': _title.text,
                'amount': amount,
                'type': _type,
                'category': _category,
                'date': _date,
                'description': _description.text,
              });
            },
          ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final accent = context.accentHighlight;
    final activeColor = selected ? accent : surfaces.border;
    return Material(
      color: selected ? accent.withValues(alpha: 0.12) : surfaces.inputFill,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: activeColor, width: selected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                Icon(Symbols.check, size: 18, color: accent),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected ? accent : surfaces.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
