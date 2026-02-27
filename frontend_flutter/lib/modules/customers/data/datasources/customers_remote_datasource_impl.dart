import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../models/customer_model.dart';
import 'customers_remote_datasource.dart';

class CustomersRemoteDataSourceImpl implements CustomersRemoteDataSource {
  CustomersRemoteDataSourceImpl(this._client);

  final DioClient _client;

  static const _salePath = '/api/sale';

  @override
  Future<List<CustomerModel>> fetchCustomers({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.dio.get('$_salePath/customers');
    final json = response.data;
    if (json is! Map<String, dynamic>) return [];
    final list = parseDataList<CustomerModel>(json, CustomerModel.fromJson);
    return list;
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
    final json = response.data;
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid response');
    }
    final data = parseData<CustomerModel>(json, CustomerModel.fromJson);
    if (data == null) throw Exception(apiMessage(json) ?? 'Tạo khách hàng thất bại');
    return data;
  }
}

final customersRemoteDataSourceProvider =
    Provider<CustomersRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return CustomersRemoteDataSourceImpl(client);
});
