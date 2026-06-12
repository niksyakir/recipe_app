import 'package:hive/hive.dart';

// This line is crucial! It tells Hive where to generate the companion file.
part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String type; // matches recipetypes.json

  @HiveField(3)
  String imagePath; // local file path for photos

  @HiveField(4)
  List<String> ingredients;

  @HiveField(5)
  List<String> steps;

  Recipe({
    required this.id,
    required this.name,
    required this.type,
    required this.imagePath,
    required this.ingredients,
    required this.steps,
  });
}
