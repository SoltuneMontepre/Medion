import '../models/ingredient_model.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/repositories/ingredients_repository.dart';

abstract class IngredientsRemoteDataSource {
  Future<IngredientsListResponse> fetchIngredients({
    int page = 1,
    int pageSize = 20,
  });

  Future<Ingredient?> fetchIngredientById(String id);

  Future<Ingredient> createIngredient(IngredientMutationParams params);

  Future<Ingredient> updateIngredient(String id, IngredientMutationParams params);

  Future<void> deleteIngredient(String id);

  Future<List<Ingredient>> suggestIngredients(String query);
}

class IngredientsListResponse {
  const IngredientsListResponse({
    required this.items,
    required this.total,
  });

  final List<IngredientModel> items;
  final int total;
}
