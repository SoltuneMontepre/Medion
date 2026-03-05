import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ingredient.dart';
import '../../domain/entities/ingredient_list_result.dart';
import '../../domain/repositories/ingredients_repository.dart';
import '../datasources/ingredients_remote_datasource.dart';
import '../datasources/ingredients_remote_datasource_impl.dart';

class IngredientsRepositoryImpl implements IngredientsRepository {
  IngredientsRepositoryImpl(this._dataSource);

  final IngredientsRemoteDataSource _dataSource;

  @override
  Future<IngredientListResult> getIngredients({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dataSource.fetchIngredients(
      page: page,
      pageSize: pageSize,
    );
    return IngredientListResult(
      items: response.items.map((m) => m.toEntity()).toList(),
      total: response.total,
    );
  }

  @override
  Future<Ingredient?> getIngredientById(String id) =>
      _dataSource.fetchIngredientById(id);

  @override
  Future<Ingredient> createIngredient(IngredientMutationParams params) =>
      _dataSource.createIngredient(params);

  @override
  Future<Ingredient> updateIngredient(String id, IngredientMutationParams params) =>
      _dataSource.updateIngredient(id, params);

  @override
  Future<void> deleteIngredient(String id) => _dataSource.deleteIngredient(id);

  @override
  Future<List<Ingredient>> suggestIngredients(String query) =>
      _dataSource.suggestIngredients(query);
}

final ingredientsRepositoryProvider = Provider<IngredientsRepository>((ref) {
  final dataSource = ref.watch(ingredientsRemoteDataSourceProvider);
  return IngredientsRepositoryImpl(dataSource);
});
