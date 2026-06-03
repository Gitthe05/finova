import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../models/category_model.dart';
import 'database_helper.dart';

class LocalCategoryDataSource {
  LocalCategoryDataSource(this._db);

  final DatabaseHelper _db;
  final _controller = StreamController<String>.broadcast();

  Stream<void> watch(String userId) async* {
    yield null;
    await for (final uid in _controller.stream) {
      if (uid == userId) yield null;
    }
  }

  Future<List<CategoryModel>> getAll(String userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'categories',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<int> count(String userId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as c FROM categories WHERE userId = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> insertAll(List<CategoryModel> models) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final model in models) {
      batch.insert(
        'categories',
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
    if (models.isNotEmpty) _notify(models.first.userId);
  }

  Future<void> upsert(CategoryModel model) async {
    final db = await _db.database;
    await db.insert(
      'categories',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _notify(model.userId);
  }

  Future<void> delete(String id, String userId) async {
    final db = await _db.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    _notify(userId);
  }

  Future<bool> existsByName({
    required String userId,
    required String name,
    required String type,
    String? excludeId,
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      'categories',
      where: excludeId == null
          ? 'userId = ? AND name = ? AND type = ?'
          : 'userId = ? AND name = ? AND type = ? AND id != ?',
      whereArgs: excludeId == null
          ? [userId, name, type]
          : [userId, name, type, excludeId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<int> countTransactionsByCategory({
    required String userId,
    required String name,
    required String type,
  }) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as c FROM transactions WHERE userId = ? AND category = ? AND type = ?',
      [userId, name, type],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  void _notify(String userId) {
    if (!_controller.isClosed) _controller.add(userId);
  }

  void dispose() => _controller.close();
}
