import 'package:uuid/uuid.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/financial_summary.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/local_transaction_datasource.dart';
import '../datasources/local/session_storage.dart';
import '../datasources/remote/remote_transaction_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required LocalTransactionDataSource local,
    required RemoteTransactionDataSource remote,
    required SessionStorage session,
  })  : _local = local,
        _remote = remote,
        _session = session;

  final LocalTransactionDataSource _local;
  final RemoteTransactionDataSource _remote;
  final SessionStorage _session;
  final _uuid = const Uuid();

  Future<String> _userId() async {
    final id = await _session.getUserId();
    if (id == null) throw Exception('Usuário não autenticado');
    return id;
  }

  Future<bool> _hasServerSession() async {
    final token = await _session.getToken();
    return token != null &&
        token.isNotEmpty &&
        !token.startsWith('local_');
  }

  List<TransactionEntity> _filter(
    List<TransactionModel> list, {
    TransactionType? type,
    String? category,
    DateTime? month,
    String? search,
  }) {
    var result = list.map((e) => e.toEntity()).toList();
    if (type != null) {
      result = result.where((t) => t.type == type).toList();
    }
    if (category != null && category.isNotEmpty) {
      result = result.where((t) => t.category == category).toList();
    }
    if (month != null) {
      result = result.where((t) {
        final d = t.date.toLocal();
        return d.year == month.year && d.month == month.month;
      }).toList();
    }
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase();
      result = result
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                (t.description?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    return result;
  }

  @override
  Future<void> syncWithServer() async {
    if (!await _hasServerSession()) return;
    final userId = await _userId();

    await _pushPending(userId);
    await _pullFromServer(userId);
  }

  Future<void> _pushPending(String userId) async {
    final all = await _local.getAll(userId);
    final queue = all.where((t) => t.syncStatus != 'synced').toList();

    for (final model in queue) {
      try {
        late final TransactionModel synced;
        if (model.syncStatus == 'pending') {
          synced = await _remote.create(model);
        } else {
          try {
            synced = await _remote.update(model);
          } on ApiException catch (e) {
            if (e.statusCode == 404) {
              synced = await _remote.create(model);
            } else {
              rethrow;
            }
          }
        }
        await _local.upsert(synced);
      } catch (_) {
        await _local.upsert(model.copyWith(syncStatus: 'failed'));
      }
    }
  }

  Future<void> _pullFromServer(String userId) async {
    try {
      final remote = await _remote.fetchAll(userId);
      final local = await _local.getAll(userId);
      final pending = local
          .where((t) => t.syncStatus == 'pending' || t.syncStatus == 'failed')
          .toList();

      await _local.deleteSyncedForUser(userId);

      for (final item in remote) {
        await _local.upsert(item);
      }
      for (final item in pending) {
        await _local.upsert(item);
      }
    } catch (_) {
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactions({
    TransactionType? type,
    String? category,
    DateTime? month,
    String? search,
  }) async {
    final userId = await _userId();
    final list = await _local.getAll(userId);
    return _filter(list, type: type, category: category, month: month, search: search);
  }

  @override
  Future<TransactionEntity> create(TransactionEntity transaction) async {
    final userId = await _userId();
    var model = TransactionModel.fromEntity(transaction);
    if (model.id.isEmpty) {
      model = TransactionModel(
        id: _uuid.v4(),
        userId: userId,
        title: model.title,
        amount: model.amount,
        type: model.type,
        category: model.category,
        description: model.description,
        date: model.date,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );
    } else {
      model = model.copyWith(syncStatus: 'pending', updatedAt: DateTime.now());
    }

    await _local.upsert(model);

    if (await _hasServerSession()) {
      try {
        final remote = await _remote.create(model);
        await _local.upsert(remote);
        return remote.toEntity();
      } catch (_) {
        await _local.upsert(model.copyWith(syncStatus: 'pending'));
      }
    }

    return model.toEntity();
  }

  @override
  Future<TransactionEntity> update(TransactionEntity transaction) async {
    var model = TransactionModel.fromEntity(
      transaction.copyWith(updatedAt: DateTime.now()),
    ).copyWith(syncStatus: 'pending');

    await _local.upsert(model);

    if (await _hasServerSession()) {
      try {
        final remote = await _remote.update(model);
        await _local.upsert(remote);
        return remote.toEntity();
      } catch (_) {
        await _local.upsert(model.copyWith(syncStatus: 'pending'));
      }
    }

    return model.toEntity();
  }

  @override
  Future<void> delete(String id) async {
    final userId = await _userId();
    final all = await _local.getAll(userId);
    TransactionModel? existing;
    for (final t in all) {
      if (t.id == id) {
        existing = t;
        break;
      }
    }

    await _local.delete(id, userId);

    if (existing != null &&
        await _hasServerSession() &&
        existing.syncStatus == 'synced') {
      try {
        await _remote.deleteRemote(id);
      } catch (_) {}
    }
  }

  @override
  Future<FinancialSummary> getSummary({DateTime? month}) async {
    final list = await getTransactions(month: month);
    return FinancialSummary.fromTransactions(list);
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions() async* {
    final userId = await _userId();
    yield await getTransactions();
    await for (final _ in _local.watchAll(userId)) {
      yield await getTransactions();
    }
  }
}

extension on TransactionEntity {
  TransactionEntity copyWith({DateTime? updatedAt}) {
    return TransactionEntity(
      id: id,
      userId: userId,
      title: title,
      amount: amount,
      type: type,
      category: category,
      description: description,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus,
    );
  }
}
