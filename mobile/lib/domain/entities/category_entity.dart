import 'package:equatable/equatable.dart';
import 'transaction_type.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String name;
  final TransactionType type;
  final String iconKey;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, userId, name, type, iconKey, createdAt];
}
