// lib/di/service_locator.dart
import 'package:get_it/get_it.dart';
import '../data/recipe_repository.dart';
import '../services/recipe_type_service.dart';
import '../services/auth_service.dart';

// This global variable is the central registry gateway
final locator = GetIt.instance;

void setupLocator() {
  // Lazy Singletons ensure these classes are only instantiated the very first time they are called,
  // saving RAM and maintaining a single source across the app lifecycle.
  locator.registerLazySingleton<RecipeRepository>(() => RecipeRepository());
  locator.registerLazySingleton<RecipeTypeService>(() => RecipeTypeService());
  locator.registerLazySingleton<AuthService>(() => AuthService());
}