import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_type.dart';

class TransactionModel {
  TransactionModel({
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
  final String type;
  final String category;
  final String? description;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      category: map['category'] as String,
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      syncStatus: map['syncStatus'] as String? ?? 'synced',
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json, String userId) {
    return TransactionModel(
      id: json['id'] as String,
      userId: userId,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: 'synced',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'description': description,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus,
      };

  Map<String, dynamic> toApiBody() => {
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'description': description,
        'date': date.toUtc().toIso8601String(),
      };

  TransactionEntity toEntity() => TransactionEntity(
        id: id,
        userId: userId,
        title: title,
        amount: amount,
        type: type == 'income' ? TransactionType.income : TransactionType.expense,
        category: category,
        description: description,
        date: date,
        createdAt: createdAt,
        updatedAt: updatedAt,
        syncStatus: syncStatus,
      );

  static TransactionModel fromEntity(TransactionEntity e) {
    return TransactionModel(
      id: e.id,
      userId: e.userId,
      title: e.title,
      amount: e.amount,
      type: e.type.apiValue,
      category: e.category,
      description: e.description,
      date: e.date,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      syncStatus: e.syncStatus,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? syncStatus,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId,
      title: title,
      amount: amount,
      type: type,
      category: category,
      description: description,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
