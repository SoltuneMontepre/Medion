import '../entities/ingredient.dart';
import '../entities/ingredient_list_result.dart';

abstract class IngredientsRepository {
  Future<IngredientListResult> getIngredients({
    int page = 1,
    int pageSize = 20,
  });

  Future<Ingredient?> getIngredientById(String id);

  Future<Ingredient> createIngredient(IngredientMutationParams params);

  Future<Ingredient> updateIngredient(String id, IngredientMutationParams params);

  Future<void> deleteIngredient(String id);

  Future<List<Ingredient>> suggestIngredients(String query);
}

class IngredientMutationParams {
  const IngredientMutationParams({
    required this.code,
    required this.name,
    this.unit = 'kg',
    this.description = '',
  });

  final String code;
  final String name;
  final String unit;
  final String description;
}
