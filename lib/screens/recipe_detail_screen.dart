// lib/screens/recipe_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import 'recipe_form_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId; 

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Dynamically look up the recipe from the provider.
    // This makes this screen completely reactive to provider updates!
    final provider = context.watch<RecipeProvider>();
    final recipes = provider.getRecipes(filterType: 'All');
    
    // Safely look up the target recipe item
    final recipeElement = recipes.where((r) => r.id == recipeId);
    
    // Defensive fallback if the recipe was deleted while on this screen
    if (recipeElement.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Recipe no longer exists.')),
      );
    }
    
    final recipe = recipeElement.first;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RecipeFormScreen(recipe: recipe)),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_rounded, color: Colors.white),
                onPressed: () => _showDeleteDialog(context, recipe),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (recipe.imagePath.isNotEmpty)
                    recipe.imagePath.startsWith('assets/')
                        ? Image.asset(recipe.imagePath, fit: BoxFit.cover)
                        : Image.file(File(recipe.imagePath), fit: BoxFit.cover)
                  else
                    Container(
                      color: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.restaurant_menu, size: 72, color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: Text(recipe.type),
                    backgroundColor: theme.colorScheme.primary.withValues(alpha:0.08),
                    side: BorderSide.none,
                    labelStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSectionHeader(context, Icons.shopping_basket_rounded, 'Ingredients'),
                  const SizedBox(height: 8),
                  
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: recipe.ingredients.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No ingredients specified.', style: TextStyle(color: Colors.black45)),
                            )
                          : Column(
                              children: recipe.ingredients.map((ing) => ListTile(
                                leading: Icon(Icons.radio_button_unchecked_rounded, size: 20, color: theme.colorScheme.primary),
                                title: Text(ing),
                                dense: true,
                              )).toList(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader(context, Icons.soup_kitchen_rounded, 'Preparation Steps'),
                  const SizedBox(height: 8),
                  
                  recipe.steps.isEmpty
                      ? const Text('No steps specified.', style: TextStyle(color: Colors.black45))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: recipe.steps.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: theme.colorScheme.primary,
                                    child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      recipe.steps[i],
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: const Color(0xFF2C1A11))),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recipe?'),
        content: Text('Are you sure you want to permanently delete "${recipe.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await Provider.of<RecipeProvider>(context, listen: false).deleteRecipe(recipe);
              if (context.mounted) {
                Navigator.pop(ctx); // Close Dialog
                Navigator.pop(context); // Pop Detail Screen back to list
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}