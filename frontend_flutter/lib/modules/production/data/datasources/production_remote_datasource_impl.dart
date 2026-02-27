import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/dio_client.dart';
import '../models/production_order_model.dart';
import 'production_remote_datasource.dart';

/// Implementation: calls API via shared Dio client. Manufacture.API backend.
class ProductionRemoteDataSourceImpl implements ProductionRemoteDataSource {
  ProductionRemoteDataSourceImpl(this._client);

  // ignore: unused_field
  final DioClient _client;

  @override
  Future<List<ProductionOrderModel>> fetchOrders({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final base = (page - 1) * pageSize;
    return List.generate(
      5,
      (i) => ProductionOrderModel(
        id: '${base + i + 1}',
        orderNumber: 'PO-${base + i + 1}',
        productName: 'Sản phẩm ${base + i + 1}',
        quantity: 100 * (i + 1),
        status: i.isEven ? 'Đang sản xuất' : 'Đã lên lịch',
        date: '2025-02-${(base + i + 1).clamp(1, 28)}',
      ),
    );
  }
}

final productionRemoteDataSourceProvider = Provider<ProductionRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductionRemoteDataSourceImpl(client);
});
