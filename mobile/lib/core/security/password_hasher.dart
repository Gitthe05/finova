import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static String hash(String password, {String? salt}) {
    final s = salt ?? 'finova_salt';
    final bytes = utf8.encode('$s:$password');
    return sha256.convert(bytes).toString();
  }

  static bool verify(String password, String hash, {String? salt}) {
    return hash == PasswordHasher.hash(password, salt: salt);
  }
}
