import 'package:sqflite/sqflite.dart';
import '../../../core/security/password_hasher.dart';
import '../../models/user_model.dart';
import 'database_helper.dart';

class LocalAuthDataSource {
  LocalAuthDataSource(this._db);
  final DatabaseHelper _db;

  Future<UserModel?> findByEmail(String email) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<UserModel> insert(UserModel user) async {
    final db = await _db.database;
    await db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.abort);
    return user;
  }

  Future<UserModel?> loginLocal(String email, String password) async {
    final user = await findByEmail(email);
    if (user == null) return null;
    if (!PasswordHasher.verify(password, user.passwordHash, salt: user.id)) {
      return null;
    }
    return user;
  }

  Future<UserModel> registerLocal({
    required String name,
    required String email,
    required String password,
    required String id,
  }) async {
    final hash = PasswordHasher.hash(password, salt: id);
    final user = UserModel(
      id: id,
      name: name,
      email: email.toLowerCase(),
      passwordHash: hash,
      createdAt: DateTime.now(),
    );
    return insert(user);
  }
}
