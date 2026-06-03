import '../../domain/entities/transaction_type.dart';

class DefaultCategorySeed {
  const DefaultCategorySeed({
    required this.name,
    required this.type,
    required this.iconKey,
  });

  final String name;
  final TransactionType type;
  final String iconKey;
}

abstract final class DefaultCategories {
  static const seeds = [
    DefaultCategorySeed(name: 'Salário', type: TransactionType.income, iconKey: 'payments'),
    DefaultCategorySeed(name: 'Freelance', type: TransactionType.income, iconKey: 'work'),
    DefaultCategorySeed(name: 'Investimentos', type: TransactionType.income, iconKey: 'trending_up'),
    DefaultCategorySeed(name: 'Outros', type: TransactionType.income, iconKey: 'category'),
    DefaultCategorySeed(name: 'Alimentação', type: TransactionType.expense, iconKey: 'restaurant'),
    DefaultCategorySeed(name: 'Transporte', type: TransactionType.expense, iconKey: 'directions_car'),
    DefaultCategorySeed(name: 'Moradia', type: TransactionType.expense, iconKey: 'home'),
    DefaultCategorySeed(name: 'Saúde', type: TransactionType.expense, iconKey: 'health'),
    DefaultCategorySeed(name: 'Lazer', type: TransactionType.expense, iconKey: 'celebration'),
    DefaultCategorySeed(name: 'Educação', type: TransactionType.expense, iconKey: 'school'),
    DefaultCategorySeed(name: 'Assinaturas', type: TransactionType.expense, iconKey: 'subscriptions'),
    DefaultCategorySeed(name: 'Outros', type: TransactionType.expense, iconKey: 'category'),
  ];
}
