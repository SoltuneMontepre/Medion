import '../models/customer_model.dart';

abstract class CustomersRemoteDataSource {
  Future<List<CustomerModel>> fetchCustomers({int page = 1, int pageSize = 20});

  Future<CustomerModel> createCustomer({
    required String name,
    required String address,
    required String phone,
  });
}
