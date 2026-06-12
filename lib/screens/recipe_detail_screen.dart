import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import 'recipe_form_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      // Listen directly to the Hive database box for any changes
      valueListenable: Hive.box<Recipe>('recipes').listenable(),
      builder: (context, Box<Recipe> box, _) {
        // Fetch the freshest copy of this specific recipe from the database using its ID
        // If it was deleted, fall back to the original instance passed in
        final currentRecipe = box.get(recipe.id) ?? recipe;

        return Scaffold(
          appBar: AppBar(
            title: Text(currentRecipe.name),
            actions: [
              // Edit Button
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Recipe',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RecipeFormScreen(existingRecipe: currentRecipe),
                  ),
                ),
              ),
              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                tooltip: 'Delete Recipe',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Recipe'),
                      content: Text(
                        'Are you sure you want to delete "${currentRecipe.name}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<RecipeProvider>().deleteRecipe(
                              currentRecipe,
                            );
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Recipe Image Banner
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: currentRecipe.imagePath.isNotEmpty
                    ? Image.file(
                        File(currentRecipe.imagePath),
                        height: 220,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 220,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
              ),
              const SizedBox(height: 12),

              // Recipe Category Tag
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(currentRecipe.type),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Ingredients Card
              Card(
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Divider(),
                      if (currentRecipe.ingredients.isEmpty)
                        const Text(
                          'No ingredients listed.',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ...currentRecipe.ingredients.map(
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Text(
                                    i,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Steps/Instructions Card
              Card(
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Divider(),
                      if (currentRecipe.steps.isEmpty)
                        const Text(
                          'No steps listed.',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ...currentRecipe.steps.asMap().entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 10,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                  child: Text(
                                    '${e.key + 1}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    e.value,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
