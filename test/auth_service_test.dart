// test/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:recipe_app/models/user_account.dart';
import 'package:recipe_app/services/auth_service.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
    
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserAccountAdapter());
    }
    
    await Hive.openBox<UserAccount>('users');
    await Hive.openBox('session');
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('no account initially', () {
    final auth = AuthService();
    expect(auth.hasAccount, isFalse);
    expect(auth.isLoggedIn, isFalse);
  });

  test('register creates account and logs in', () async {
    final auth = AuthService();
    final success = await auth.register('alice', 'password123');

    expect(success, isTrue);
    expect(auth.hasAccount, isTrue);
    expect(auth.isLoggedIn, isTrue);
    expect(auth.currentUser, 'alice');
  });

  test('register fails for duplicate username', () async {
    final auth = AuthService();
    await auth.register('alice', 'password123');

    final secondAttempt = await auth.register('alice', 'differentPass');

    expect(secondAttempt, isFalse);
  });

  test('login succeeds with correct credentials', () async {
    final auth = AuthService();
    await auth.register('alice', 'password123');
    await auth.logout();

    final success = await auth.login('alice', 'password123');

    expect(success, isTrue);
    expect(auth.isLoggedIn, isTrue);
  });

  test('login fails with wrong password', () async {
    final auth = AuthService();
    await auth.register('alice', 'password123');
    await auth.logout();

    final success = await auth.login('alice', 'wrongPassword');

    expect(success, isFalse);
    expect(auth.isLoggedIn, isFalse);
  });

  test('logout clears session', () async {
    final auth = AuthService();
    await auth.register('alice', 'password123');

    await auth.logout();

    expect(auth.isLoggedIn, isFalse);
    expect(auth.hasAccount, isTrue);
  });

  test('password is stored hashed, not plain text', () async {
    final auth = AuthService();
    await auth.register('alice', 'password123');

    final box = Hive.box<UserAccount>('users');
    final stored = box.get('alice');

    expect(stored, isNotNull);
    expect(stored!.passwordHash, isNot(equals('password123')));
    expect(stored.passwordHash.length, 64);
  });
}