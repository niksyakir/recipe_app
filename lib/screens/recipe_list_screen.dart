import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  // 'All' is selected by default so the user sees everything initially
  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    // Watch provider to get the available categories loaded from the JSON
    final provider = context.watch<RecipeProvider>();
    final types = ['All', ...provider.recipeTypes];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipe Book'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Category Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.filter_list),
              ),
              items: types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedType = val);
                }
              },
            ),
          ),
          
          // The Reactive Recipe List
          Expanded(
            child: ValueListenableBuilder(
              // Listens directly to changes inside the Hive 'recipes' box
              valueListenable: Hive.box<Recipe>('recipes').listenable(),
              builder: (context, Box<Recipe> box, _) {
                // Fetch the filtered list from our provider logic
                final recipes = provider.getRecipes(filterType: _selectedType);
                
                if (recipes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No recipes found.\nTap + to add your first one!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final r = recipes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        // If the recipe has an image path, show it; otherwise show a fallback icon
                        leading: r.imagePath.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: FileImage(File(r.imagePath)),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.restaurant_menu),
                              ),
                        title: Text(
                          r.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(r.type),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailScreen(recipe: r),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Floating Action Button to navigate to the creation form
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecipeFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}