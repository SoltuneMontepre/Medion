import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/inventory_item_model.dart';
import 'inventory_remote_datasource.dart';

/// Implementation: calls API via shared Dio client.
class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  InventoryRemoteDataSourceImpl(this._client);

  /// Used when real API is available: _client.dio.get(...)
  // ignore: unused_field
  final DioClient _client;

  @override
  Future<List<InventoryItemModel>> fetchItems({
    int page = 1,
    int pageSize = 20,
  }) async {
    // Placeholder: no backend yet. Return sample data.
    await Future.delayed(const Duration(milliseconds: 300));
    return List.generate(
      5,
      (i) => InventoryItemModel(
        id: '${(page - 1) * pageSize + i + 1}',
        code: 'ITEM-${(page - 1) * pageSize + i + 1}',
        name: 'Sample Item ${(page - 1) * pageSize + i + 1}',
      ),
    );
  }
}

final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return InventoryRemoteDataSourceImpl(client);
});
