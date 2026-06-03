import 'package:equatable/equatable.dart';
import 'transaction_type.dart';

class TransactionEntity extends Equatable {
  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
  });

  final String id;
  final String userId;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final String? description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        amount,
        type,
        category,
        description,
        date,
        syncStatus,
      ];
}
