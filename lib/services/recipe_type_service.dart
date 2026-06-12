// lib/services/recipe_type_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class RecipeTypeService {
  static const _url =
      'https://raw.githubusercontent.com/niksyakir/recipe_app/main/assets/data/recipetypes.json';

  /// Fetches recipe types from the hosted JSON. Falls back to the bundled
  /// asset if the network is unavailable — keeps the app usable offline.
  Future<List<String>> fetchRecipeTypes() async {
    try {
      final response = await http.get(Uri.parse(_url)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['recipeTypes']);
      }
      throw Exception('Bad response: ${response.statusCode}');
    } catch (_) {
      // Offline fallback safety net
      final jsonStr = await rootBundle.loadString('assets/data/recipetypes.json');
      final data = json.decode(jsonStr);
      return List<String>.from(data['recipeTypes']);
    }
  }
}