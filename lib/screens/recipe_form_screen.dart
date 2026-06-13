// lib/screens/recipe_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe? recipe; // If null, we are adding. If not null, we are editing!

  const RecipeFormScreen({super.key, this.recipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _selectedType;
  late String _imagePath;
  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _stepControllers;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _name = r?.name ?? '';
    _imagePath = r?.imagePath ?? '';
    
    // Fallback logic handled beautifully for provider state initialization
    final provider = Provider.of<RecipeProvider>(context, listen: false);
    if (r != null) {
      _selectedType = r.type;
    } else {
      _selectedType = provider.recipeTypes.isNotEmpty ? provider.recipeTypes.first : 'Breakfast';
    }

    _ingredientControllers = (r?.ingredients ?? [''])
        .map((ing) => TextEditingController(text: ing))
        .toList();

    _stepControllers = (r?.steps ?? [''])
        .map((step) => TextEditingController(text: step))
        .toList();
  }

  @override
  void dispose() {
    for (var c in _ingredientControllers) {
      c.dispose();
    }
    for (var c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final ingredients = _ingredientControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    final steps = _stepControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    final provider = Provider.of<RecipeProvider>(context, listen: false);
    
    if (widget.recipe == null) {
      // Create Operation
      final newRecipe = Recipe(
        id: const Uuid().v4(),
        name: _name,
        type: _selectedType,
        imagePath: _imagePath,
        ingredients: ingredients,
        steps: steps,
      );
      await provider.addRecipe(newRecipe);
    } else {
      // Update Operation
      widget.recipe!.name = _name;
      widget.recipe!.type = _selectedType;
      widget.recipe!.imagePath = _imagePath;
      widget.recipe!.ingredients = ingredients;
      widget.recipe!.steps = steps;
      await provider.updateRecipe(widget.recipe!);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final theme = Theme.of(context);
    final isEditing = widget.recipe != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Recipe' : 'Add Recipe', style: theme.textTheme.titleLarge),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Picker Visual Field Container
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha:0.15)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.02), blurRadius: 10)],
                ),
                child: _imagePath.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(File(_imagePath), fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded, size: 48, color: theme.colorScheme.primary),
                          const SizedBox(height: 8),
                          const Text('Tap to upload food image', style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w500)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Basic details group card
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('General Info', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(labelText: 'Recipe Title', prefixIcon: Icon(Icons.restaurant_rounded)),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a recipe title' : null,
                      onSaved: (val) => _name = val!.trim(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(labelText: 'Recipe Category', prefixIcon: Icon(Icons.category_rounded)),
                      items: provider.recipeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ingredients Dynamic Array Card
            _buildDynamicCardSection(
              context: context,
              title: 'Ingredients',
              icon: Icons.shopping_basket_rounded,
              controllers: _ingredientControllers,
              hintText: 'e.g., 2 cups of Flour',
              onAdd: () => setState(() => _ingredientControllers.add(TextEditingController())),
              onRemove: (index) => setState(() => _ingredientControllers.removeAt(index).dispose()),
            ),
            const SizedBox(height: 24),

            // Steps Dynamic Array Card
            _buildDynamicCardSection(
              context: context,
              title: 'Preparation Steps',
              icon: Icons.soup_kitchen_rounded,
              controllers: _stepControllers,
              hintText: 'e.g., Bake for 25 minutes at 180°C',
              onAdd: () => setState(() => _stepControllers.add(TextEditingController())),
              onRemove: (index) => setState(() => _stepControllers.removeAt(index).dispose()),
            ),
            const SizedBox(height: 32),

            // Main CTA Submission Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              onPressed: _saveForm,
              child: Text(isEditing ? 'Save Structural Updates' : 'Publish Recipe', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicCardSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<TextEditingController> controllers,
    required String hintText,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                  ],
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: onAdd,
                  style: IconButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                )
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha:0.1),
                        child: Text('${index + 1}', style: TextStyle(fontSize: 11, color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: controllers[index],
                          decoration: InputDecoration(
                            hintText: hintText,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          validator: (val) => index == 0 && (val == null || val.trim().isEmpty) ? 'First row value cannot be empty' : null,
                        ),
                      ),
                      if (controllers.length > 1)
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline_rounded, color: theme.colorScheme.error.withValues(alpha:0.7)),
                          onPressed: () => onRemove(index),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}