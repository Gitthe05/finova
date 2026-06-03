import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_type.dart';

class CategoryModel {
  CategoryModel({
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
  final String type;
  final String iconKey;
  final String createdAt;

  factory CategoryModel.fromMap(Map<String, Object?> map) {
    return CategoryModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      iconKey: map['iconKey'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'type': type,
        'iconKey': iconKey,
        'createdAt': createdAt,
      };

  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        userId: userId,
        name: name,
        type: TransactionType.values.firstWhere((e) => e.name == type),
        iconKey: iconKey,
        createdAt: DateTime.parse(createdAt),
      );

  static CategoryModel fromEntity(CategoryEntity entity) => CategoryModel(
        id: entity.id,
        userId: entity.userId,
        name: entity.name,
        type: entity.type.name,
        iconKey: entity.iconKey,
        createdAt: entity.createdAt.toIso8601String(),
      );
}
