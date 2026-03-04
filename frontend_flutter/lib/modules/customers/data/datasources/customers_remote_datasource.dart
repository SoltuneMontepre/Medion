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
    required String name,
    required String address,
    required String phone,
  });

  /// GET /api/v1/sale/customers/suggest?q=...
  Future<List<CustomerModel>> suggestCustomers(String query);
}
