// lib/screens/recipe_list_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';
import '../screens/auth_gate.dart';
import '../di/service_locator.dart';
import '../services/auth_service.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipe Book'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Inside RecipeListScreen AppBar actions
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await locator<AuthService>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthGate()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      // Use FutureBuilder to wait for network/JSON load
      body: FutureBuilder<void>(
        future: provider.typesLoaded,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final types = ['All', ...provider.recipeTypes];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
              ),
              Expanded(
                // Use StreamBuilder for real-time reactivity
                child: StreamBuilder<BoxEvent>(
                  stream: Hive.box<Recipe>('recipes').watch(),
                  builder: (context, _) {
                    final recipes = provider.getRecipes(filterType: _selectedType);
                    if (recipes.isEmpty) {
                      return const Center(child: Text('No recipes found. Tap + to add!'));
                    }
                    return ListView.builder(
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final r = recipes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: r.imagePath.isNotEmpty
                                ? CircleAvatar(backgroundImage: FileImage(File(r.imagePath)))
                                : const CircleAvatar(child: Icon(Icons.restaurant_menu)),
                            title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(r.type),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: r))),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}