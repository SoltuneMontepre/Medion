import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/inventory_balance.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';
import '../datasources/inventory_remote_datasource_impl.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl(this._dataSource);

  final InventoryRemoteDataSource _dataSource;

  @override
  Future<List<InventoryItem>> getItems({int page = 1, int pageSize = 20}) async {
    final models = await _dataSource.fetchItems(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<({List<InventoryBalance> items, int total})> getBalance({
    required String warehouseType,
    int page = 1,
    int pageSize = 20,
  }) async {
    final result = await _dataSource.fetchBalance(
      warehouseType: warehouseType,
      page: page,
      pageSize: pageSize,
    );
    return (
      items: result.items.map((m) => m.toEntity()).toList(),
      total: result.total,
    );
  }
}

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final dataSource = ref.watch(inventoryRemoteDataSourceProvider);
  return InventoryRepositoryImpl(dataSource);
});
