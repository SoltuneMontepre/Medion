import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/order_summary.dart';
import '../models/order_detail_model.dart';
import '../models/product_suggest_model.dart';
import '../models/sale_order_model.dart';
import 'sales_remote_datasource.dart';

/// Implementation: calls API via shared Dio client.
class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  SalesRemoteDataSourceImpl(this._client);

  final DioClient _client;

  static const _salePath = '/api/v1/sale';

  @override
  Future<List<SaleOrderModel>> fetchOrders({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.dio.get(
      '$_salePath/orders',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final json = response.data;
    if (json is! Map<String, dynamic>) return [];
    final data = json['data'];
    if (data is! Map<String, dynamic>) return [];
    final items = data['items'];
    if (items is! List) return [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(SaleOrderModel.fromJson)
        .toList();
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
    final data = json['data'];
    if (data is Map<String, dynamic> && data['items'] is List) {
      final list = parseDataList<OrderSummaryItem>(json, _orderSummaryItemFromJson);
      return OrderSummary(summaryDate: dateYyyyMmDd, items: list);
    }
    return OrderSummary(summaryDate: dateYyyyMmDd, items: []);
  }

  @override
  Future<CheckCustomerOrderTodayResult> checkCustomerOrderToday(
      String customerId) async {
    final response = await _client.dio.get(
      '$_salePath/orders/check-today',
      queryParameters: {'customerId': customerId},
    );
    final json = response.data;
    if (json is! Map<String, dynamic>) {
      return const CheckCustomerOrderTodayResult(hasOrderToday: false);
    }
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return const CheckCustomerOrderTodayResult(hasOrderToday: false);
    }
    final hasOrderToday = data['hasOrderToday'] as bool? ?? false;
    final existingId = data['existingOrderId']?.toString();
    final nextNumber = data['nextOrderNumber'] as String?;
    return CheckCustomerOrderTodayResult(
      hasOrderToday: hasOrderToday,
      existingOrderId: existingId,
      nextOrderNumber: nextNumber,
    );
  }

  @override
  Future<OrderDetailModel> createOrder({
    required String customerId,
    required List<OrderItemRequest> items,
    required String pin,
  }) async {
    final body = {
      'customerId': customerId,
      'items': items
          .map((e) => {'productId': e.productId, 'quantity': e.quantity})
          .toList(),
      'pin': pin,
    };
    final response = await _client.dio.post('$_salePath/orders', data: body);
    final json = response.data;
    if (json is! Map<String, dynamic>) throw Exception('Invalid response');
    final data = parseData<OrderDetailModel>(json, OrderDetailModel.fromJson);
    if (data == null) throw Exception(apiMessage(json) ?? 'Lưu đơn thất bại');
    return data;
  }

  @override
  Future<OrderDetailModel> getOrderById(String orderId) async {
    final response = await _client.dio.get('$_salePath/orders/$orderId');
    final json = response.data;
    if (json is! Map<String, dynamic>) throw Exception('Invalid response');
    final data = parseData<OrderDetailModel>(json, OrderDetailModel.fromJson);
    if (data == null) throw Exception(apiMessage(json) ?? 'Không tìm thấy đơn hàng');
    return data;
  }

  @override
  Future<List<ProductSuggestModel>> fetchProductSuggest(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await _client.dio.get(
      '$_salePath/products/suggest',
      queryParameters: {'q': query.trim()},
    );
    final json = response.data;
    if (json is! Map<String, dynamic>) return [];
    final list = parseDataList<ProductSuggestModel>(
        json, ProductSuggestModel.fromJson);
    return list;
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
