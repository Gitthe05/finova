import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/transaction_type.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/gradient_button.dart';

class CategoryFormBottomSheet extends StatefulWidget {
  const CategoryFormBottomSheet({super.key, this.category});

  final CategoryEntity? category;

  @override
  State<CategoryFormBottomSheet> createState() => _CategoryFormBottomSheetState();
}

class _CategoryFormBottomSheetState extends State<CategoryFormBottomSheet> {
  late final _name = TextEditingController(text: widget.category?.name ?? '');
  late TransactionType _type =
      widget.category?.type ?? TransactionType.expense;
  String? _error;

  bool get _isEditing => widget.category != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            _isEditing ? 'Editar categoria' : 'Nova categoria',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppTokens.spaceMd),
          if (!_isEditing) ...[
            Row(
              children: [
                Expanded(
                  child: _TypeChip(
                    label: 'Receita',
                    selected: _type == TransactionType.income,
                    color: AppColors.success,
                    onTap: () => setState(() => _type = TransactionType.income),
                  ),
                ),
                const SizedBox(width: AppTokens.spaceSm),
                Expanded(
                  child: _TypeChip(
                    label: 'Despesa',
                    selected: _type == TransactionType.expense,
                    color: AppColors.danger,
                    onTap: () => setState(() => _type = TransactionType.expense),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.spaceMd),
          ],
          AppTextField(
            controller: _name,
            label: 'Nome',
            hint: 'Ex: Viagens',
            textInputAction: TextInputAction.done,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTokens.spaceSm),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.danger,
                  ),
            ),
          ],
          const SizedBox(height: AppTokens.spaceLg),
          GradientButton(
            label: _isEditing ? 'Salvar alterações' : 'Criar categoria',
            onPressed: () {
              final name = _name.text.trim();
              if (name.length < 2) {
                setState(() => _error = 'Nome deve ter pelo menos 2 caracteres');
                return;
              }
              Navigator.pop(context, {
                'id': widget.category?.id,
                'name': name,
                'type': _type,
              });
            },
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.15)
                : surfaces.inputFill,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(
              color: selected ? color : surfaces.border,
              width: selected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? color : surfaces.textSecondary,
                ),
          ),
        ),
      ),
    );
  }
}
