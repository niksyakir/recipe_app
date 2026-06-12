import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'di/service_locator.dart';
import 'models/recipe.dart';
import 'providers/recipe_provider.dart';
import 'screens/recipe_list_screen.dart';
import 'data/recipe_repository.dart';
import 'services/recipe_type_service.dart';
import 'models/user_account.dart';
import 'screens/auth_gate.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local Hive database
  await Hive.initFlutter();
  
  // Register and open Recipe Box
  Hive.registerAdapter(RecipeAdapter());
  await Hive.openBox<Recipe>('recipes');

  // Register and open Auth Boxes
  Hive.registerAdapter(UserAccountAdapter());
  await Hive.openBox<UserAccount>('users');
  await Hive.openBox('session'); // Untyped box for session flags

  setupLocator();

  runApp(
    ChangeNotifierProvider(
      create: (_) => RecipeProvider(
        repo: locator<RecipeRepository>(),
        typeService: locator<RecipeTypeService>(),
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
      ),
      home: const AuthGate(),
    );
  }
}