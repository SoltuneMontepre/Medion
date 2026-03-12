import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/order_summary.dart';
import '../../domain/entities/sale_order.dart';
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
  Future<OrdersListResponse> fetchOrders(OrdersListQuery query) async {
    final params = <String, dynamic>{
      'page': query.page,
      'pageSize': query.pageSize,
    };
    if (query.search.trim().isNotEmpty) params['search'] = query.search.trim();
    if (query.dateFilter != null && query.dateFilter!.isNotEmpty) {
      params['dateFilter'] = query.dateFilter!.toLowerCase();
    }
    if (query.status.trim().isNotEmpty) params['status'] = query.status.trim();
    if (query.sortBy.trim().isNotEmpty) params['sortBy'] = query.sortBy.trim();
    if (query.sortOrder.trim().isNotEmpty) params['sortOrder'] = query.sortOrder.trim();

    final response = await _client.dio.get(
      '$_salePath/orders',
      queryParameters: params,
    );
    final json = response.data;
    if (json is! Map<String, dynamic>) {
      return const OrdersListResponse(items: [], total: 0);
    }
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return const OrdersListResponse(items: [], total: 0);
    }
    final itemsList = data['items'];
    final total = (data['total'] as num?)?.toInt() ?? 0;
    if (itemsList is! List) {
      return OrdersListResponse(items: [], total: total);
    }
    final items = itemsList
        .whereType<Map<String, dynamic>>()
        .map(SaleOrderModel.fromJson)
        .toList();
    return OrdersListResponse(items: items, total: total);
  }

  @override
  Future<OrderSummaryListResult> fetchOrderSummaries({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.dio.get(
      '$_salePath/order-summaries',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final json = response.data;
    if (json is! Map<String, dynamic>) {
      return const OrderSummaryListResult(items: [], total: 0);
    }
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return const OrderSummaryListResult(items: [], total: 0);
    }
    final itemsList = data['items'];
    final total = (data['total'] as num?)?.toInt() ?? 0;
    if (itemsList is! List) {
      return OrderSummaryListResult(items: [], total: total);
    }
    final items = <OrderSummaryListEntry>[];
    for (final e in itemsList) {
      if (e is Map<String, dynamic>) {
        items.add(_orderSummaryListEntryFromJson(e));
      }
    }
    return OrderSummaryListResult(items: items, total: total);
  }

  @override
  Future<OrderSummary?> fetchOrderSummaryByDate(String dateYyyyMmDd) async {
    try {
      final response = await _client.dio.get(
        '$_salePath/order-summaries/by-date',
        queryParameters: {'date': dateYyyyMmDd},
      );
      final json = response.data;
      if (json is! Map<String, dynamic>) return null;
      final data = json['data'];
      if (data is! Map<String, dynamic>) return null;
      return _orderSummaryDetailFromJson(data);
    } on Exception {
      return null;
    }
  }

  @override
  Future<OrderSummary?> fetchOrderSummaryById(String id) async {
    try {
      final response = await _client.dio.get('$_salePath/order-summaries/$id');
      final json = response.data;
      if (json is! Map<String, dynamic>) return null;
      final data = json['data'];
      if (data is! Map<String, dynamic>) return null;
      return _orderSummaryDetailFromJson(data);
    } on Exception {
      return null;
    }
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
    final status = response.statusCode ?? 0;
    final json = response.data;

    // Success (2xx): treat as created even if parsing fails, so we never show error when order was created.
    if (status >= 200 && status < 300) {
      if (json is Map<String, dynamic>) {
        try {
          final data = parseData<OrderDetailModel>(json, OrderDetailModel.fromJson);
          if (data != null) return data;
        } catch (_) {}
        // Fallback: extract at least id from envelope so UI can show success and navigate.
        final raw = json['data'];
        if (raw is Map<String, dynamic>) {
          final id = raw['id']?.toString();
          if (id != null && id.isNotEmpty) {
            return OrderDetailModel(
              id: id,
              orderNumber: raw['orderNumber'] as String? ?? '',
              customerId: raw['customerId']?.toString() ?? customerId,
              customerCode: raw['customerCode'] as String? ?? '',
              customerName: raw['customerName'] as String? ?? '',
              orderDate: raw['orderDate']?.toString() ?? '',
              status: raw['status'] as String? ?? '',
              items: [],
            );
          }
        }
      }
      // No parseable body but 2xx: still treat as success with minimal model so user sees success.
      return OrderDetailModel(
        id: '',
        orderNumber: '',
        customerId: customerId,
        customerCode: '',
        customerName: '',
        orderDate: '',
        status: '',
        items: [],
      );
    }

    throw Exception(
      json is Map<String, dynamic>
          ? (apiMessage(json) ?? 'Lưu đơn thất bại')
          : 'Lưu đơn thất bại',
    );
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

OrderSummaryListEntry _orderSummaryListEntryFromJson(Map<String, dynamic> json) {
  final summaryDate = json['summaryDate'];
  DateTime createdAt = DateTime.now();
  if (summaryDate != null && summaryDate is String) {
    createdAt = DateTime.tryParse(summaryDate) ?? createdAt;
  }
  final createdStr = json['createdAt']?.toString();
  if (createdStr != null) {
    createdAt = DateTime.tryParse(createdStr) ?? createdAt;
  }
  return OrderSummaryListEntry(
    id: json['id']?.toString() ?? '',
    ownerId: json['ownerId']?.toString() ?? '',
    summaryDate: json['summaryDate']?.toString() ?? '',
    createdAt: createdAt,
    itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
  );
}

OrderSummary? _orderSummaryDetailFromJson(Map<String, dynamic> json) {
  final id = json['id']?.toString() ?? '';
  final ownerId = json['ownerId']?.toString() ?? '';
  final summaryDate = json['summaryDate']?.toString() ?? '';
  final createdAtStr = json['createdAt']?.toString();
  final createdAt =
      createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
  final itemsJson = json['items'];
  final items = <OrderSummaryItem>[];
  if (itemsJson is List) {
    for (final e in itemsJson) {
      if (e is Map<String, dynamic>) {
        items.add(_orderSummaryItemFromJson(e));
      }
    }
  }
  return OrderSummary(
    id: id,
    ownerId: ownerId,
    summaryDate: summaryDate,
    createdAt: createdAt ?? DateTime.now(),
    approvedBy: json['approvedBy']?.toString(),
    items: items,
  );
}

OrderSummaryItem _orderSummaryItemFromJson(Map<String, dynamic> json) {
  return OrderSummaryItem(
    productCode: json['productCode'] as String? ?? '',
    productName: json['productName'] as String? ?? '',
    packageSize: json['packageSize'] as String? ?? '',
    packageUnit: json['packageUnit'] as String? ?? '',
    productType: json['productType'] as String? ?? '',
    packagingType: json['packagingType'] as String? ?? '',
    quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  );
}

final salesRemoteDataSourceProvider = Provider<SalesRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return SalesRemoteDataSourceImpl(client);
});
