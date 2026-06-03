import 'package:equatable/equatable.dart';
import 'transaction_entity.dart';
import 'transaction_type.dart';

class FinancialSummary extends Equatable {
  const FinancialSummary({
    required this.income,
    required this.expense,
    required this.balance,
    required this.count,
  });

  final double income;
  final double expense;
  final double balance;
  final int count;

  factory FinancialSummary.fromTransactions(List<TransactionEntity> list) {
    var income = 0.0;
    var expense = 0.0;
    for (final t in list) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    return FinancialSummary(
      income: income,
      expense: expense,
      balance: income - expense,
      count: list.length,
    );
  }

  @override
  List<Object?> get props => [income, expense, balance, count];
}
