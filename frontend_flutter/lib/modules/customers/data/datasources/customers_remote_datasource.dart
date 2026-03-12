import '../models/customer_model.dart';

/// Raw response from API: items + total count.
class CustomersListResponse {
  const CustomersListResponse({required this.items, required this.total});
  final List<CustomerModel> items;
  final int total;
}

abstract class CustomersRemoteDataSource {
  Future<CustomersListResponse> fetchCustomers({int page = 1, int pageSize = 20});

  Future<CustomerModel> createCustomer({
    required String code,
    required String name,
    required String address,
    required String phone,
    String contactPerson = '',
  });

  /// GET /api/v1/sale/customers/suggest?q=...
  Future<List<CustomerModel>> suggestCustomers(String query);

  /// GET /api/v1/sale/customers/:id
  Future<CustomerModel> getCustomerById(String id);

  Future<CustomerModel> updateCustomer({
    required String id,
    required String name,
    required String address,
    required String phone,
    String contactPerson = '',
  });

  Future<void> deleteCustomer(String id);
}
