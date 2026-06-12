import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/recipe.dart';
import 'providers/recipe_provider.dart';
import 'screens/recipe_list_screen.dart';

void main() async {
  // Ensures Flutter's internal bindings are ready before we run async database code
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Local Database storage
  await Hive.initFlutter();
  
  // 2. Register the generated adapter
  Hive.registerAdapter(RecipeAdapter());
  
  // 3. Open the actual storage box file
  await Hive.openBox<Recipe>('recipes');

  runApp(
    // Wrap the entire app in a ChangeNotifierProvider so all screens can access recipes
    ChangeNotifierProvider(
      create: (_) => RecipeProvider(),
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
        colorSchemeSeed: Colors.deepOrange, // warm culinary app theme
      ),
      home: const RecipeListScreen(), 
    );
  }
}