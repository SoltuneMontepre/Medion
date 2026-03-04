import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../models/customer_model.dart';
import 'customers_remote_datasource.dart';

class CustomersRemoteDataSourceImpl implements CustomersRemoteDataSource {
  CustomersRemoteDataSourceImpl(this._client);

  final DioClient _client;

  static const _salePath = '/api/v1/sale';

  @override
  Future<CustomersListResponse> fetchCustomers({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.dio.get(
      '$_salePath/customers',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final json = response.data;
    if (json is! Map<String, dynamic>) {
      return const CustomersListResponse(items: [], total: 0);
    }
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final items = data['items'] is List
          ? (data['items'] as List)
              .whereType<Map<String, dynamic>>()
              .map(CustomerModel.fromJson)
              .toList()
          : <CustomerModel>[];
      final totalRaw = data['total'];
      final total = totalRaw is int ? totalRaw : items.length;
      return CustomersListResponse(items: items, total: total);
    }
    if (data is List) {
      final list = data
          .whereType<Map<String, dynamic>>()
          .map(CustomerModel.fromJson)
          .toList();
      return CustomersListResponse(items: list, total: list.length);
    }
    return const CustomersListResponse(items: [], total: 0);
  }

  @override
  Future<CustomerModel> createCustomer({
    required String name,
    required String address,
    required String phone,
  }) async {
    final body = {
      'name': name,
      'address': address,
      'phone': phone,
    };
    final response =
        await _client.dio.post('$_salePath/customers', data: body);
    final raw = response.data;
    // Handle both Map (Dio default) and String (some servers double-encode or return string body)
    final Map<String, dynamic>? json = raw is Map<String, dynamic>
        ? raw
        : (raw is String && raw.isNotEmpty)
            ? (jsonDecode(raw) as Map<String, dynamic>?)
            : null;
    if (json == null) {
      throw Exception(
        apiMessage({}) ?? 'Phản hồi không hợp lệ từ máy chủ (tạo khách hàng có thể đã thành công).',
      );
    }
    final data = parseData<CustomerModel>(json, CustomerModel.fromJson);
    if (data == null) {
      throw Exception(apiMessage(json) ?? 'Tạo khách hàng thất bại');
    }
    return data;
  }

  @override
  Future<List<CustomerModel>> suggestCustomers(String query) async {
    if (query.trim().isEmpty) return [];
    final response = await _client.dio.get(
      '$_salePath/customers/suggest',
      queryParameters: {'q': query.trim()},
    );
    final json = response.data;
    if (json is! Map<String, dynamic>) return [];
    final list = parseDataList<CustomerModel>(json, CustomerModel.fromJson);
    return list;
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    final response = await _client.dio.get('$_salePath/customers/$id');
    final raw = response.data;
    final Map<String, dynamic>? json = raw is Map<String, dynamic>
        ? raw
        : (raw is String && raw.isNotEmpty)
            ? (jsonDecode(raw) as Map<String, dynamic>?)
            : null;
    if (json == null) throw Exception('Phản hồi không hợp lệ');
    final data = parseData<CustomerModel>(json, CustomerModel.fromJson);
    if (data == null) throw Exception('Không tìm thấy khách hàng');
    return data;
  }

  @override
  Future<CustomerModel> updateCustomer({
    required String id,
    required String name,
    required String address,
    required String phone,
  }) async {
    final body = {'name': name, 'address': address, 'phone': phone};
    final response = await _client.dio.put('$_salePath/customers/$id', data: body);
    final raw = response.data;
    final Map<String, dynamic>? json = raw is Map<String, dynamic>
        ? raw
        : (raw is String && raw.isNotEmpty)
            ? (jsonDecode(raw) as Map<String, dynamic>?)
            : null;
    if (json == null) throw Exception(apiMessage({}) ?? 'Cập nhật thất bại');
    final data = parseData<CustomerModel>(json, CustomerModel.fromJson);
    if (data == null) throw Exception(apiMessage(json) ?? 'Cập nhật khách hàng thất bại');
    return data;
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _client.dio.delete('$_salePath/customers/$id');
  }
}

final customersRemoteDataSourceProvider =
    Provider<CustomersRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return CustomersRemoteDataSourceImpl(client);
});
