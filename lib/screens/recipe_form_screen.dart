import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class RecipeFormScreen extends StatefulWidget {
  final Recipe?
  existingRecipe; // If null, we are creating a new recipe. If not null, we are editing.
  const RecipeFormScreen({super.key, this.existingRecipe});

  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _nameController = TextEditingController();
  late List<TextEditingController> _ingredientControllers;
  late List<TextEditingController> _stepControllers;
  String? _selectedType;
  String _imagePath = '';

  @override
  void initState() {
    super.initState();
    final r = widget.existingRecipe;

    // If editing, fill the fields with existing data. If new, leave them blank/default.
    _nameController.text = r?.name ?? '';
    _selectedType = r?.type;
    _imagePath = r?.imagePath ?? '';

    // Initialize dynamic text fields with at least one empty box if it's a new recipe
    _ingredientControllers = (r?.ingredients ?? [''])
        .map((e) => TextEditingController(text: e))
        .toList();
    _stepControllers = (r?.steps ?? [''])
        .map((e) => TextEditingController(text: e))
        .toList();
  }

  // Uses the image_picker package to grab a photo from the local gallery
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe name')),
      );
      return;
    }

    final provider = context.read<RecipeProvider>();

    // Gather values from all dynamic text fields, ignoring blank inputs
    final ingredients = _ingredientControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final steps = _stepControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final recipe = Recipe(
      id: widget.existingRecipe?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      type: _selectedType ?? provider.recipeTypes.first,
      imagePath: _imagePath,
      ingredients: ingredients,
      steps: steps,
    );

    if (widget.existingRecipe != null) {
      provider.updateRecipe(recipe);
    } else {
      provider.addRecipe(recipe);
    }

    Navigator.pop(context); // Go back to the previous screen
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var c in _ingredientControllers) {
      c.dispose();
    }
    for (var c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingRecipe == null ? 'New Recipe' : 'Edit Recipe',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image Picker Frame
          GestureDetector(
            onTap: _pickImage,
            child: _imagePath.isNotEmpty
                ? Image.file(File(_imagePath), height: 180, fit: BoxFit.cover)
                : Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Recipe Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue:
                _selectedType ??
                (provider.recipeTypes.isNotEmpty
                    ? provider.recipeTypes.first
                    : null),
            decoration: const InputDecoration(
              labelText: 'Recipe Category',
              border: OutlineInputBorder(),
            ),
            items: provider.recipeTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (val) => setState(() => _selectedType = val),
          ),
          const SizedBox(height: 24),

          // Dynamic Ingredients Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ingredients',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton.icon(
                onPressed: () => setState(
                  () => _ingredientControllers.add(TextEditingController()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          ..._buildDynamicFields(
            _ingredientControllers,
            'e.g., 2 cups of flour',
          ),
          const SizedBox(height: 24),

          // Dynamic Steps Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Instructions Steps',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton.icon(
                onPressed: () => setState(
                  () => _stepControllers.add(TextEditingController()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          ..._buildDynamicFields(
            _stepControllers,
            'e.g., Bake for 20 minutes',
            isNumbered: true,
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Save Recipe', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicFields(
    List<TextEditingController> controllers,
    String hint, {
    bool isNumbered = false,
  }) {
    return List.generate(controllers.length, (i) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            if (isNumbered)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 12,
                  child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                ),
              ),
            Expanded(
              child: TextField(
                controller: controllers[i],
                decoration: InputDecoration(
                  hintText: hint,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.redAccent,
              ),
              onPressed: () {
                if (controllers.length > 1) {
                  setState(() => controllers.removeAt(i));
                } else {
                  setState(() => controllers[i].clear());
                }
              },
            ),
          ],
        ),
      );
    });
  }
}
