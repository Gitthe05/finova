import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../../models/transaction_model.dart';
import 'database_helper.dart';

class LocalTransactionDataSource {
  LocalTransactionDataSource(this._db);

  final DatabaseHelper _db;
  final _controller = StreamController<void>.broadcast();

  Stream<void> watchAll(String userId) => _controller.stream;

  Future<List<TransactionModel>> getAll(String userId) async {
    final db = await _db.database;
    final rows = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return rows.map(TransactionModel.fromMap).toList();
  }

  Future<void> upsert(TransactionModel model) async {
    final db = await _db.database;
    await db.insert(
      'transactions',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _refresh(userId: model.userId);
  }

  Future<void> delete(String id, String userId) async {
    final db = await _db.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    await _refresh(userId: userId);
  }

  Future<void> deleteSyncedForUser(String userId) async {
    final db = await _db.database;
    await db.delete(
      'transactions',
      where: 'userId = ? AND syncStatus = ?',
      whereArgs: [userId, 'synced'],
    );
    await _refresh(userId: userId);
  }

  Future<void> _refresh({required String userId}) async {
    if (!_controller.isClosed) _controller.add(null);
  }

  void dispose() => _controller.close();
}
