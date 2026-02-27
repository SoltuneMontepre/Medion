import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/get_inventory_items.dart';
import '../../data/repositories_impl/inventory_repository_impl.dart';

/// Async state: loading/error/data. Scoped per module.
final inventoryItemsProvider = FutureProvider.autoDispose.family<List<InventoryItem>, int>((ref, page) {
  final repository = ref.watch(inventoryRepositoryProvider);
  final useCase = GetInventoryItems(repository);
  return useCase(page: page, pageSize: 20);
});
