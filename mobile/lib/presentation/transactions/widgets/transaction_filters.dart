import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../domain/entities/transaction_type.dart';

class TransactionFilters extends StatelessWidget {
  const TransactionFilters({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.onMonthPick,
    this.selectedMonth,
    this.padding,
  });

  final TransactionType? selectedType;
  final ValueChanged<TransactionType?> onTypeChanged;
  final VoidCallback onMonthPick;
  final DateTime? selectedMonth;
  final EdgeInsetsGeometry? padding;

  String get _monthLabel {
    if (selectedMonth == null) return 'Todos os meses';
    final formatted = DateFormat('MMMM yyyy', 'pt_BR').format(selectedMonth!);
    if (formatted.isEmpty) return 'Todos os meses';
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final accent = context.accentHighlight;
    final horizontal = padding ??
        const EdgeInsets.symmetric(horizontal: AppTokens.spaceMd);

    return Padding(
      padding: horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: surfaces.segmentTrack,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              border: Border.all(color: surfaces.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TypeSegment(
                    label: 'Todas',
                    selected: selectedType == null,
                    onTap: () => onTypeChanged(null),
                    accent: accent,
                    surfaces: surfaces,
                  ),
                ),
                Expanded(
                  child: _TypeSegment(
                    label: 'Receitas',
                    selected: selectedType == TransactionType.income,
                    onTap: () => onTypeChanged(TransactionType.income),
                    accentColor: AppColors.success,
                    surfaces: surfaces,
                  ),
                ),
                Expanded(
                  child: _TypeSegment(
                    label: 'Despesas',
                    selected: selectedType == TransactionType.expense,
                    onTap: () => onTypeChanged(TransactionType.expense),
                    accentColor: AppColors.danger,
                    surfaces: surfaces,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.spaceSm),
          Material(
            color: surfaces.inputFill,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            child: InkWell(
              onTap: onMonthPick,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.spaceMd,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(
                    color: selectedMonth != null ? accent : surfaces.border,
                    width: selectedMonth != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Symbols.calendar_month,
                      size: 20,
                      color: selectedMonth != null ? accent : surfaces.textMuted,
                    ),
                    const SizedBox(width: AppTokens.spaceSm),
                    Text(
                      'Período',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: surfaces.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: AppTokens.spaceSm),
                    Expanded(
                      child: Text(
                        _monthLabel,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: selectedMonth != null
                                  ? accent
                                  : surfaces.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Symbols.chevron_right,
                      size: 20,
                      color: surfaces.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeSegment extends StatelessWidget {
  const _TypeSegment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.surfaces,
    this.accent,
    this.accentColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppSurfaceColors surfaces;
  final Color? accent;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final active = accentColor ?? accent ?? context.accentHighlight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? (accentColor != null
                    ? active.withValues(alpha: 0.2)
                    : surfaces.card)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            border: selected && accentColor == null
                ? Border.all(color: active.withValues(alpha: 0.4))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? active : surfaces.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
