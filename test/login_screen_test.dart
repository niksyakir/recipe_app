// test/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:recipe_app/models/user_account.dart';
import 'package:recipe_app/screens/login_screen.dart';
import 'package:recipe_app/services/auth_service.dart'; 

void main() {
  final sl = GetIt.instance; // Access the GetIt container instance

  setUp(() async {
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserAccountAdapter());
    }
    await Hive.openBox<UserAccount>('users');
    await Hive.openBox('session');

    // Register a fresh AuthService into GetIt before each test run
    if (!sl.isRegistered<AuthService>()) {
      sl.registerLazySingleton<AuthService>(() => AuthService());
    }
  });

  tearDown(() async {
    await tearDownTestHive();
    // Reset GetIt to keep the environment clean for subsequent runs
    await sl.reset();
  });

  testWidgets('renders login screen elements successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Login'), findsWidgets);
    expect(find.text('Invalid username or password'), findsNothing);
  });

  testWidgets('shows validation warning banner on invalid credentials matching', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextField).first, 'unregistered_user');
    await tester.enterText(find.byType(TextField).last, 'wrong_password_123');

    final loginButton = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    
    await tester.pumpAndSettle();

    expect(find.text('Invalid username or password'), findsOneWidget);
  });
}