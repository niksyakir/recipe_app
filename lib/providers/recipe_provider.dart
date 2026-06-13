// lib/providers/recipe_provider.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/recipe_repository.dart';
import '../models/recipe.dart';
import '../services/recipe_type_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _repo;
  final RecipeTypeService _typeService;
  List<String> recipeTypes = [];
  late final Future<void> typesLoaded;

  // Constructor handles clean dependency injection
  RecipeProvider({RecipeRepository? repo, RecipeTypeService? typeService})
      : _repo = repo ?? RecipeRepository(),
        _typeService = typeService ?? RecipeTypeService() {
    typesLoaded = _loadTypes();
  }

  Future<void> _loadTypes() async {
    recipeTypes = await _typeService.fetchRecipeTypes();
    if (_repo.getAll().isEmpty) _seedSampleData();
    notifyListeners();
  }

  void _seedSampleData() {
    final uuid = const Uuid();
    final samples = [
      Recipe(
        id: uuid.v4(),
        name: 'Nasi Lemak',
        type: 'Breakfast',
        imagePath: 'assets/images/nasi lemak.jpg',
        ingredients: ['Rice', 'Coconut milk', 'Anchovies', 'Egg', 'Cucumber'],
        steps: [
          'Cook rice with coconut milk',
          'Fry anchovies',
          'Serve with egg and cucumber',
        ],
      ),
      Recipe(
        id: uuid.v4(),
        name: 'Chicken Rendang',
        type: 'Lunch',
        imagePath: 'assets/images/rendang.jpg',
        ingredients: ['Chicken', 'Coconut milk', 'Rendang paste', 'Lemongrass'],
        steps: [
          'Marinate chicken with paste',
          'Simmer with coconut milk until dry',
          'Serve with rice',
        ],
      ),
      Recipe(
        id: uuid.v4(),
        name: 'Mee Goreng',
        type: 'Dinner',
        imagePath: 'assets/images/mee goreng.jpg',
        ingredients: ['Yellow noodles', 'Egg', 'Bean sprouts', 'Chili sauce'],
        steps: [
          'Stir fry noodles with chili sauce',
          'Add egg and bean sprouts',
          'Toss until cooked',
        ],
      ),
      Recipe(
        id: uuid.v4(),
        name: 'Cendol',
        type: 'Dessert',
        imagePath: 'assets/images/cendol.jpg',
        ingredients: [
          'Pandan jelly',
          'Coconut milk',
          'Palm sugar syrup',
          'Shaved ice',
        ],
        steps: [
          'Layer ice with pandan jelly',
          'Pour coconut milk',
          'Drizzle palm sugar syrup',
        ],
      ),
      Recipe(
        id: uuid.v4(),
        name: 'Pisang Goreng',
        type: 'Snack',
        imagePath: 'assets/images/pisang goreng.jpg',
        ingredients: [
          'Banana',
          'Flour',
          'Rice flour',
          'Sugar',
          'Oil for frying',
        ],
        steps: [
          'Mix flour batter',
          'Coat banana slices',
          'Deep fry until golden',
        ],
      ),
      Recipe(
        id: uuid.v4(),
        name: 'Teh Tarik',
        type: 'Beverage',
        imagePath: 'assets/images/teh tarik.jpg',
        ingredients: ['Black tea', 'Condensed milk', 'Sugar'],
        steps: [
          'Brew strong black tea',
          'Add condensed milk',
          'Pour back and forth to create foam',
        ],
      ),
    ];
    for (final r in samples) {
      _repo.box.put(r.id, r);
    }
  }

  List<Recipe> getRecipes({String? filterType}) {
    final all = _repo.getAll();
    if (filterType == null || filterType == 'All') return all;
    return all.where((r) => r.type == filterType).toList();
  }

  Future<void> addRecipe(Recipe r) => _repo.add(r);
  
  Future<void> updateRecipe(Recipe r) async {
    await _repo.update(r);
    notifyListeners();
  }
  
  Future<void> deleteRecipe(Recipe r) => _repo.delete(r);
}