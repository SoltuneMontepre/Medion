import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/create_customer_params.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_list_result.dart';
import '../../domain/errors/customer_exceptions.dart';
import '../../domain/repositories/customers_repository.dart';
import '../datasources/customers_remote_datasource.dart';
import '../datasources/customers_remote_datasource_impl.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  CustomersRepositoryImpl(this._dataSource);

  final CustomersRemoteDataSource _dataSource;

  @override
  Future<CustomerListResult> getCustomers({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response =
        await _dataSource.fetchCustomers(page: page, pageSize: pageSize);
    return CustomerListResult(
      items: response.items.map((m) => m.toEntity()).toList(),
      total: response.total,
    );
  }

  @override
  Future<Customer> createCustomer(CreateCustomerParams params) async {
    try {
      final code = params.code?.trim() ?? '';
      final model = await _dataSource.createCustomer(
        code: code,
        name: params.name,
        address: params.address,
        phone: params.phone,
        contactPerson: params.contactPerson,
      );
      return model.toEntity();
    } on DioException catch (e) {
      _throwIfDuplicatePhone(e);
      _throwIfDuplicateCode(e);
      rethrow;
    }
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    try {
      final model = await _dataSource.getCustomerById(id);
      return model.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Customer> updateCustomer(String id, CreateCustomerParams params) async {
    try {
      final model = await _dataSource.updateCustomer(
        id: id,
        name: params.name,
        address: params.address,
        phone: params.phone,
        contactPerson: params.contactPerson,
      );
      return model.toEntity();
    } on DioException catch (e) {
      _throwIfDuplicatePhone(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await _dataSource.deleteCustomer(id);
  }

  void _throwIfDuplicatePhone(DioException e) {
    final msg = _extractMessage(e);
    final statusCode = e.response?.statusCode;
    if (statusCode == 409 ||
        (statusCode == 400 &&
            (msg.toLowerCase().contains('điện thoại') ||
                msg.toLowerCase().contains('số điện thoại')))) {
      throw CustomerDuplicatePhoneException(
        msg.isNotEmpty
            ? msg
            : 'Số điện thoại này đã tồn tại trong hệ thống. Vui lòng kiểm tra lại.',
      );
    }
  }

  void _throwIfDuplicateCode(DioException e) {
    final msg = _extractMessage(e);
    final statusCode = e.response?.statusCode;
    if (statusCode == 409 ||
        (statusCode == 400 &&
            msg.toLowerCase().contains('mã khách hàng'))) {
      throw CustomerDuplicateCodeException(
        msg.isNotEmpty ? msg : null,
      );
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
