import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/inventory_balance_model.dart';
import '../models/inventory_item_model.dart';
import 'inventory_remote_datasource.dart';

/// Implementation: calls API via shared Dio client.
class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  InventoryRemoteDataSourceImpl(this._client);

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

  @override
  Future<({List<InventoryBalanceModel> items, int total})> fetchBalance({
    required String warehouseType,
    int page = 1,
    int pageSize = 20,
  }) async {
    final res = await _client.dio.get<Map<String, dynamic>>(
      '/api/v1/inventory',
      queryParameters: {
        'warehouseType': warehouseType,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = res.data;
    if (data == null) return (items: <InventoryBalanceModel>[], total: 0);
    final rawList = data['data'] as Map<String, dynamic>?;
    if (rawList == null) return (items: <InventoryBalanceModel>[], total: 0);
    final list = rawList['items'] as List<dynamic>? ?? [];
    final total = (rawList['total'] as num?)?.toInt() ?? 0;
    final List<InventoryBalanceModel> items = list
        .map((e) => InventoryBalanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items: items, total: total);
  }
}

final inventoryRemoteDataSourceProvider = Provider<InventoryRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return InventoryRemoteDataSourceImpl(client);
});
