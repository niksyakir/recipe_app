// lib/services/auth_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import '../models/user_account.dart';

class AuthService {
  final Box<UserAccount> _userBox = Hive.box<UserAccount>('users');
  final Box _sessionBox = Hive.box('session');

  // Converts plain text password into an unreadable SHA-256 string
  String _hash(String input) => sha256.convert(utf8.encode(input)).toString();

  bool get hasAccount => _userBox.isNotEmpty;
  bool get isLoggedIn => _sessionBox.get('loggedInUser') != null;
  String? get currentUser => _sessionBox.get('loggedInUser') as String?;

  Future<bool> register(String username, String password) async {
    if (_userBox.containsKey(username)) return false;
    await _userBox.put(username, UserAccount(username: username, passwordHash: _hash(password)));
    await _sessionBox.put('loggedInUser', username);
    return true;
  }

  Future<bool> login(String username, String password) async {
    final user = _userBox.get(username);
    if (user == null || user.passwordHash != _hash(password)) return false;
    await _sessionBox.put('loggedInUser', username);
    return true;
  }

  Future<void> logout() async => _sessionBox.delete('loggedInUser');
}