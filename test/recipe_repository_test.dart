// test/recipe_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/data/recipe_repository.dart';

void main() {
  setUp(() async {
    await setUpTestHive();
    // Safely check and register adapter for test isolation
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RecipeAdapter());
    }
    await Hive.openBox<Recipe>('recipes');
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  group('RecipeRepository Unit Tests', () {
    test('starts empty', () {
      final repo = RecipeRepository();
      expect(repo.getAll(), isEmpty);
    });

    test('add stores a recipe', () async {
      final repo = RecipeRepository();
      final recipe = Recipe(
        id: '1',
        name: 'Test Recipe',
        type: 'Breakfast',
        imagePath: '',
        ingredients: ['Egg'],
        steps: ['Fry the egg'],
      );

      await repo.add(recipe);

      expect(repo.getAll().length, 1);
      expect(repo.getAll().first.name, 'Test Recipe');
    });

    test('delete removes a recipe', () async {
      final repo = RecipeRepository();
      final recipe = Recipe(
        id: '2',
        name: 'To Delete',
        type: 'Lunch',
        ingredients: [],
        steps: [],
        imagePath: '',
      );

      await repo.add(recipe);
      expect(repo.getAll().length, 1);

      await repo.delete(recipe);
      expect(repo.getAll(), isEmpty);
    });
  });
}