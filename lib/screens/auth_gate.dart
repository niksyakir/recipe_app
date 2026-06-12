// lib/screens/auth_gate.dart
import 'package:flutter/material.dart';
import '../di/service_locator.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'recipe_list_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = locator<AuthService>();
    if (auth.isLoggedIn) return const RecipeListScreen();
    return auth.hasAccount ? const LoginScreen() : const RegisterScreen();
  }
}