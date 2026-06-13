// lib/screens/recipe_list_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../di/service_locator.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';
import '../services/auth_service.dart';
import 'auth_gate.dart';
import 'recipe_detail_screen.dart';
import 'recipe_form_screen.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Recipe Book', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
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
      body: FutureBuilder<void>(
        future: provider.typesLoaded,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeWidth: 3),
                  SizedBox(height: 16),
                  Text('Fetching fresh categories...', style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
                ],
              ),
            );
          }

          final types = ['All', ...provider.recipeTypes];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Filter Dropdown Container
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Filter by Category',
                    prefixIcon: Icon(Icons.filter_list_rounded, color: theme.colorScheme.primary),
                  ),
                  items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
              ),

              // Dynamic List Section
              Expanded(
                child: StreamBuilder<BoxEvent>(
                  stream: Hive.box<Recipe>('recipes').watch(),
                  builder: (context, _) {
                    final recipes = provider.getRecipes(filterType: _selectedType);
                    
                    if (recipes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu_rounded, size: 64, color: theme.colorScheme.primary.withValues(alpha:0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'No recipes found',
                              style: theme.textTheme.titleMedium?.copyWith(color: Colors.black54),
                            ),
                            const SizedBox(height: 8),
                            const Text('Tap the + button to add your first culinary masterpiece!', style: TextStyle(color: Colors.black38)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80), // Prevent FAB overlap
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final r = recipes[index];
                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: r))
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Recipe Image Container
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      width: 85,
                                      height: 85,
                                      color: theme.colorScheme.primary.withValues(alpha:0.05),
                                      child: r.imagePath.isNotEmpty
                                          ? Image.file(File(r.imagePath), fit: BoxFit.cover)
                                          : Icon(Icons.cookie_outlined, size: 36, color: theme.colorScheme.primary.withValues(alpha:0.5)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Recipe Details Text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.name,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2C1A11),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        
                                        // Category Chip/Badge UI
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withValues(alpha:0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            r.type,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: theme.colorScheme.primary.withValues(alpha:0.4)),
                                ],
                              ),
                            ),
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
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}