import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories_impl/ingredients_repository_impl.dart';
import '../../domain/entities/ingredient_list_result.dart';

final ingredientsProvider =
    FutureProvider.family<IngredientListResult, int>((ref, page) async {
  final repo = ref.watch(ingredientsRepositoryProvider);
  return repo.getIngredients(page: page, pageSize: 20);
});
