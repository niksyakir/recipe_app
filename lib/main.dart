import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'data/recipe_repository.dart';
import 'di/service_locator.dart';
import 'models/recipe.dart';
import 'models/user_account.dart';
import 'providers/recipe_provider.dart';
import 'screens/auth_gate.dart';
import 'services/recipe_type_service.dart';

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
  await Hive.openBox('session');

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
        // Generates a complete, cohesive palette from a single anchor color
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
          surface: const Color(0xFFFDF8F5), // Soft off-white warmth
        ),
        
        // Professional, clean typography scaling
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C1A11)),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
          bodyMedium: TextStyle(color: Colors.black87, height: 1.4),
        ),

        // Modern, subtle input boxes (no heavy borders)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.deepOrange.withValues(alpha:0.15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.deepOrange.withValues(alpha:0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 1.5),
          ),
          labelStyle: const TextStyle(color: Colors.black54),
        ),

        // Custom global styling for Cards
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha:0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // Premium styling for modern Floating Action Buttons
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
      ),
      home: const AuthGate(),
    );
  }
}