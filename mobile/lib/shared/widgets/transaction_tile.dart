import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_type.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  final TransactionEntity transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppColors.success : AppColors.danger;
    return Semantics(
      label: '${transaction.title}, ${AppFormatters.money(transaction.amount)}',
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            isIncome ? Symbols.arrow_downward : Symbols.arrow_upward,
            color: color,
            size: 20,
          ),
        ),
        title: Text(transaction.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${transaction.category} · ${AppFormatters.date.format(transaction.date)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${AppFormatters.money(transaction.amount)}',
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Symbols.delete, size: 20),
                onPressed: onDelete,
                tooltip: 'Excluir',
              ),
          ],
        ),
      ),
    );
  }
}
