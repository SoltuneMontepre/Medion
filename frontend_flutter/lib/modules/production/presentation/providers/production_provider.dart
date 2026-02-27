import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/production_order.dart';
import '../../domain/usecases/get_production_orders.dart';
import '../../data/repositories_impl/production_repository_impl.dart';

/// Async state: loading/error/data. Scoped per module.
final productionOrdersProvider =
    FutureProvider.autoDispose.family<List<ProductionOrder>, int>((ref, page) {
  final repository = ref.watch(productionRepositoryProvider);
  final useCase = GetProductionOrders(repository);
  return useCase(page: page, pageSize: 20);
});
