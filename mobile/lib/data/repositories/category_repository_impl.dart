import 'package:uuid/uuid.dart';
import '../../core/constants/default_categories.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/local_category_datasource.dart';
import '../datasources/local/session_storage.dart';
import '../models/category_model.dart';

class CategoryRepositoryException implements Exception {
  CategoryRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl({
    required LocalCategoryDataSource local,
    required SessionStorage session,
  })  : _local = local,
        _session = session;

  final LocalCategoryDataSource _local;
  final SessionStorage _session;
  final _uuid = const Uuid();

  Future<String> _userId() async {
    final id = await _session.getUserId();
    if (id == null) throw CategoryRepositoryException('Usuário não autenticado');
    return id;
  }

  Future<void> _ensureSeeded(String userId) async {
    if (await _local.count(userId) > 0) return;
    final now = DateTime.now().toIso8601String();
    final models = DefaultCategories.seeds
        .map(
          (seed) => CategoryModel(
            id: _uuid.v4(),
            userId: userId,
            name: seed.name,
            type: seed.type.name,
            iconKey: seed.iconKey,
            createdAt: now,
          ),
        )
        .toList();
    await _local.insertAll(models);
  }

  @override
  Stream<List<CategoryEntity>> watchCategories() async* {
    final userId = await _userId();
    await _ensureSeeded(userId);
    await for (final _ in _local.watch(userId)) {
      final list = await _local.getAll(userId);
      yield list.map((e) => e.toEntity()).toList();
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final userId = await _userId();
    await _ensureSeeded(userId);
    final list = await _local.getAll(userId);
    return list.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> saveCategory({
    String? id,
    required String name,
    required String type,
    String iconKey = 'category',
  }) async {
    final userId = await _userId();
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw CategoryRepositoryException('Informe o nome da categoria');
    }
    if (trimmed.length < 2) {
      throw CategoryRepositoryException('Nome deve ter pelo menos 2 caracteres');
    }

    final exists = await _local.existsByName(
      userId: userId,
      name: trimmed,
      type: type,
      excludeId: id,
    );
    if (exists) {
      throw CategoryRepositoryException('Já existe uma categoria com este nome');
    }

    CategoryModel model;
    if (id != null) {
      final existing = (await _local.getAll(userId)).where((c) => c.id == id).firstOrNull;
      if (existing == null) {
        throw CategoryRepositoryException('Categoria não encontrada');
      }
      model = CategoryModel(
        id: id,
        userId: userId,
        name: trimmed,
        type: existing.type,
        iconKey: existing.iconKey,
        createdAt: existing.createdAt,
      );
    } else {
      model = CategoryModel(
        id: _uuid.v4(),
        userId: userId,
        name: trimmed,
        type: type,
        iconKey: iconKey,
        createdAt: DateTime.now().toIso8601String(),
      );
    }
    await _local.upsert(model);
  }

  @override
  Future<void> deleteCategory(String id) async {
    final userId = await _userId();
    final categories = await _local.getAll(userId);
    final target = categories.where((c) => c.id == id).firstOrNull;
    if (target == null) {
      throw CategoryRepositoryException('Categoria não encontrada');
    }

    final usage = await _local.countTransactionsByCategory(
      userId: userId,
      name: target.name,
      type: target.type,
    );
    if (usage > 0) {
      throw CategoryRepositoryException(
        'Não é possível excluir: $usage transação(ões) usam esta categoria',
      );
    }

    await _local.delete(id, userId);
  }

  @override
  Future<int> countTransactionsUsing(String name, String type) {
    return _userId().then(
      (userId) => _local.countTransactionsByCategory(
        userId: userId,
        name: name,
        type: type,
      ),
    );
  }
}
