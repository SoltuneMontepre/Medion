import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inventory_balance.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/get_inventory_items.dart';
import '../../data/repositories_impl/inventory_repository_impl.dart';

/// Async state: loading/error/data. Scoped per module.
final inventoryItemsProvider = FutureProvider.autoDispose.family<List<InventoryItem>, int>((ref, page) {
  final repository = ref.watch(inventoryRepositoryProvider);
  final useCase = GetInventoryItems(repository);
  return useCase(page: page, pageSize: 20);
});

/// Key for tồn kho hiện tại by warehouse section and page.
typedef InventoryBalanceKey = ({String warehouseType, int page});

/// Tồn kho hiện tại: list and total from API.
final inventoryBalanceProvider = FutureProvider.autoDispose.family<
    ({List<InventoryBalance> items, int total}),
    InventoryBalanceKey>((ref, key) async {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.getBalance(
    warehouseType: key.warehouseType,
    page: key.page,
    pageSize: 20,
  );
});
