import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories_impl/products_repository_impl.dart';
import '../../domain/entities/product_list_result.dart';
import '../../domain/usecases/get_products.dart';

final productsProvider =
    FutureProvider.autoDispose.family<ProductListResult, int>((ref, page) {
  final repository = ref.watch(productsRepositoryProvider);
  final useCase = GetProducts(repository);
  return useCase(page: page, pageSize: 20);
});
