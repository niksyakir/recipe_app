import 'package:hive/hive.dart';
import '../models/recipe.dart';

class RecipeRepository {
  // Access the Hive box named 'recipes' that we will open in main.dart
  final Box<Recipe> _box = Hive.box<Recipe>('recipes');

  // Grab all recipes currently saved in the database
  List<Recipe> getAll() => _box.values.toList();

  // Create/Add a new recipe using its unique ID as the database key
  Future<void> add(Recipe recipe) => _box.put(recipe.id, recipe);

  // Update an existing recipe using Hive's built-in save method
  Future<void> update(Recipe recipe) => recipe.save();

  // Delete a recipe entirely from the database
  Future<void> delete(Recipe recipe) => recipe.delete();

  // Expose the raw box so UI can listen for live database changes later
  Box<Recipe> get box => _box;
}