import 'ingredient.dart';

class IngredientListResult {
  const IngredientListResult({
    required this.items,
    required this.total,
  });

  final List<Ingredient> items;
  final int total;
}
