import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/create_customer_params.dart';
import '../../domain/entities/customer.dart';
import '../../domain/errors/customer_exceptions.dart';
import '../../domain/repositories/customers_repository.dart';
import '../datasources/customers_remote_datasource.dart';
import '../datasources/customers_remote_datasource_impl.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  CustomersRepositoryImpl(this._dataSource);

  final CustomersRemoteDataSource _dataSource;

  @override
  Future<List<Customer>> getCustomers({
    int page = 1,
    int pageSize = 20,
  }) async {
    final models =
        await _dataSource.fetchCustomers(page: page, pageSize: pageSize);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Customer> createCustomer(CreateCustomerParams params) async {
    try {
      final model = await _dataSource.createCustomer(
        name: params.name,
        address: params.address,
        phone: params.phone,
      );
      return model.toEntity();
    } on DioException catch (e) {
      final msg = _extractMessage(e);
      if (e.response?.statusCode == 400 &&
          (msg.toLowerCase().contains('đã tồn tại') ||
              msg.toLowerCase().contains('duplicate') ||
              msg.toLowerCase().contains('already exists'))) {
        throw CustomerDuplicatePhoneException(
          'Số điện thoại này đã tồn tại trong hệ thống. Vui lòng kiểm tra lại.',
        );
      }
      rethrow;
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? '';
    }
    return e.message ?? '';
  }
}

final customersRepositoryProvider = Provider<CustomersRepository>((ref) {
  final dataSource = ref.watch(customersRemoteDataSourceProvider);
  return CustomersRepositoryImpl(dataSource);
});
