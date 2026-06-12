import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../data/recipe_repository.dart';
import '../models/recipe.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _repo = RecipeRepository();
  List<String> recipeTypes = [];

  RecipeProvider() {
    // Automatically load the categories from JSON as soon as the app starts
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    // Read the static JSON file we registered in pubspec.yaml
    final jsonStr = await rootBundle.loadString('assets/data/recipetypes.json');
    final data = json.decode(jsonStr);
    
    // Parse the JSON array into a standard Dart List of Strings
    recipeTypes = List<String>.from(data['recipeTypes']);
    
    // If the database is completely empty on first launch, seed a default recipe
    if (_repo.getAll().isEmpty) _seedSampleData();
    
    // Tell the UI widgets to refresh and display the loaded categories
    notifyListeners();
  }

  void _seedSampleData() {
    final uuid = const Uuid();
    _repo.add(Recipe(
      id: uuid.v4(),
      name: 'Nasi Lemak',
      type: recipeTypes.contains('Breakfast') ? 'Breakfast' : recipeTypes.first,
      imagePath: '',
      ingredients: ['Rice', 'Coconut milk', 'Anchovies', 'Egg', 'Cucumber'],
      steps: ['Cook rice with coconut milk', 'Fry anchovies', 'Serve with egg and cucumber'],
    ));
  }

  // Handles filtering the UI list by selected dropdown category
  List<Recipe> getRecipes({String? filterType}) {
    final all = _repo.getAll();
    if (filterType == null || filterType == 'All') return all;
    return all.where((r) => r.type == filterType).toList();
  }

  // Wrapper functions to bridge actions between the UI layer and the Data Repository
  Future<void> addRecipe(Recipe r) => _repo.add(r);
  Future<void> updateRecipe(Recipe r) => _repo.update(r);
  Future<void> deleteRecipe(Recipe r) => _repo.delete(r);
}