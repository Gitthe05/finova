enum TransactionType {
  income,
  expense;

  String get label => this == TransactionType.income ? 'Receita' : 'Despesa';
  String get apiValue => name;
}
