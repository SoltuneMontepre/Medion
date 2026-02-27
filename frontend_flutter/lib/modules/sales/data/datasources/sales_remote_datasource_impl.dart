import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/order_summary.dart';
import '../models/sale_order_model.dart';
import 'sales_remote_datasource.dart';

/// Implementation: calls API via shared Dio client.
class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  SalesRemoteDataSourceImpl(this._client);

  final DioClient _client;

  static const _salePath = '/api/sale';

  @override
  Future<List<SaleOrderModel>> fetchOrders({
    int page = 1,
    int pageSize = 20,
  }) async {
    // Backend has no list-orders endpoint yet; keep mock until added.
    await Future.delayed(const Duration(milliseconds: 300));
    final base = (page - 1) * pageSize;
    return List.generate(
      5,
      (i) => SaleOrderModel(
        id: '${base + i + 1}',
        orderNumber: 'SO-${base + i + 1}',
        customerName: 'Khách hàng ${base + i + 1}',
        date: '2025-02-${(base + i + 1).clamp(1, 28)}',
        totalAmount: 100.0 * (i + 1),
        status: i.isEven ? 'Hoàn thành' : 'Chờ xử lý',
      ),
    );
  }

  @override
  Future<OrderSummary> fetchDailyOrderSummary(String dateYyyyMmDd) async {
    final response = await _client.dio.get(
      '$_salePath/orders/daily-summary',
      queryParameters: {'date': dateYyyyMmDd},
    );
    final json = response.data;
    if (json is! Map<String, dynamic>) {
      return OrderSummary(summaryDate: dateYyyyMmDd, items: []);
    }
    final list = parseDataList<OrderSummaryItem>(json, _orderSummaryItemFromJson);
    return OrderSummary(summaryDate: dateYyyyMmDd, items: list);
  }
}

OrderSummaryItem _orderSummaryItemFromJson(Map<String, dynamic> json) {
  return OrderSummaryItem(
    ordinal: (json['stt'] as num?)?.toInt() ?? 0,
    productCode: json['productCode'] as String? ?? '',
    productName: json['productName'] as String? ?? '',
    specification: json['specification'] as String? ?? '',
    productForm: json['form'] as String? ?? '',
    packagingForm: json['packaging'] as String? ?? '',
    totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? 0,
  );
}

final salesRemoteDataSourceProvider = Provider<SalesRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return SalesRemoteDataSourceImpl(client);
});
