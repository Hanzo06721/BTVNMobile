import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import '../utils/database_helper.dart';

class AuthController {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  String _hash(String input) => sha256.convert(utf8.encode(input)).toString();

  Future<bool> isEmailExist(String email) async {
    final db = await _dbHelper.database;
    final rows = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return rows.isNotEmpty;
  }

  /// Trả về null nếu đăng ký thành công, ngược lại trả về thông báo lỗi.
  Future<String?> register(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Vui lòng nhập đầy đủ email và mật khẩu';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Email không hợp lệ';
    }
    if (password.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    if (await isEmailExist(email)) return 'Email này đã được đăng ký';

    final db = await _dbHelper.database;
    await db.insert(
      'users',
      User(email: email, password: _hash(password)).toMap(),
    );
    return null;
  }

  /// Đăng nhập: đúng email + password thì trả về true.
  Future<bool> login(String email, String password) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, _hash(password)],
    );
    return rows.isNotEmpty;
  }
}
